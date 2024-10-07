import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/speak_with_ai_repository.dart';
import 'speak_with_ai_event.dart';
import 'speak_with_ai_state.dart';
import '../../domain/models/message.dart';
import '../../domain/models/roleplay_feedback.dart';
import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';

class SpeakWithAIBloc extends Bloc<SpeakWithAIEvent, SpeakWithAIState> {
  final SpeakWithAIRepository _repository;
  StreamSubscription? _wsSubscription;
  final Logger _logger = Logger();
  String? _lastKnownWsUrl;
  String? _userId;

  SpeakWithAIBloc(this._repository) : super(SpeakWithAIInitial()) {
    on<StartRoleplay>(_onStartRoleplay);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<EndRoleplay>(_onEndRoleplay);
    on<ResetRoleplay>((event, emit) {
      emit(SpeakWithAIInitial());
    });
  }

  void _onStartRoleplay(StartRoleplay event, Emitter<SpeakWithAIState> emit) async {
    _logger.i('Starting roleplay with scenario: ${event.scenario}');
    emit(SpeakWithAILoading());
    try {
      final response = await _repository.startRoleplay(event.scenario);
      _logger.i('Roleplay started. Connecting to WebSocket: ${response['wsUrl']}');
      _lastKnownWsUrl = response['wsUrl'];
      _userId = response['userId'];
      final conversationId = response['conversationId'];
      await _repository.connectWebSocket(_lastKnownWsUrl!, _userId!, conversationId);
      _listenToWebSocket();
      emit(SpeakWithAIConversation(
        conversationId: conversationId,
        messages: [Message(
          content: response['initialPrompt'],
          isAI: true,
          audioBuffer: response['audioBuffer']
        )],
      ));
      _logger.i('Emitted initial conversation state');
    } catch (e) {
      _logger.e('Error starting roleplay: $e');
      emit(SpeakWithAIError(e.toString()));
    }
  }

  void _listenToWebSocket() {
    _logger.i('Setting up WebSocket listener');
    _wsSubscription = _repository.aiResponses.listen(
      (data) {
        _logger.i('Received WebSocket data: $data');
        if (data is String) {
          // If data is a string, try to parse it as JSON
          try {
            data = jsonDecode(data);
          } catch (e) {
            _logger.e('Failed to parse WebSocket data as JSON: $e');
            return;
          }
        }
        if (data is Map<String, dynamic>) {
          if (data['intent'] == 'end_roleplay') {
            // First, add the final AI message
            add(ReceiveMessage(data['aiResponse'], data['audioBuffer']));
            // Then, end the roleplay
            add(EndRoleplay(RoleplayFeedback.fromJson(data['feedback'])));
          } else {
            add(ReceiveMessage(data['aiResponse'], data['audioBuffer']));
          }
        } else {
          _logger.w('Received unexpected WebSocket data format: $data');
        }
      },
      onError: (error) {
        _logger.e('WebSocket error: $error');
        add(ReceiveMessage('Error: $error', null));
      },
    );
  }

  void _onSendMessage(SendMessage event, Emitter<SpeakWithAIState> emit) async {
    _logger.i('Sending message: ${event.message}');
    if (!_repository.isWebSocketConnected()) {
      _logger.w('WebSocket is not connected. Attempting to reconnect...');
      await _reconnectWebSocket();
    }
    if (state is SpeakWithAIConversation) {
      final currentState = state as SpeakWithAIConversation;
      final newState = currentState.copyWith(
        messages: [...currentState.messages, Message(
          content: event.message,
          isAI: false
        )],
        isLoading: true,
      );
      emit(newState);
      _repository.sendMessage(currentState.conversationId, event.message);
      _logger.i('Message sent, waiting for AI response');
      
      // Add timeout with cancellation
      bool responseReceived = false;
      Timer? timeoutTimer;
      
      timeoutTimer = Timer(Duration(seconds: 50), () {
        if (!responseReceived) {
          _logger.w('AI response timeout');
          if (state is SpeakWithAIConversation && (state as SpeakWithAIConversation).isLoading) {
            emit((state as SpeakWithAIConversation).copyWith(isLoading: false));
            add(ReceiveMessage('AI response timeout. Please try again.', null));
          }
        }
      });

      // Listen for the next ReceiveMessage event
      StreamSubscription? subscription;
      subscription = stream.listen((newState) {
        if (newState is SpeakWithAIConversation && !newState.isLoading) {
          responseReceived = true;
          timeoutTimer?.cancel();
          subscription?.cancel();
        }
      });
    } else {
      _logger.w('Attempted to send message while not in conversation state');
    }
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<SpeakWithAIState> emit) {
    _logger.i('Received AI message: ${event.message}');
    if (state is SpeakWithAIConversation) {
      final currentState = state as SpeakWithAIConversation;
      emit(currentState.copyWith(
        messages: [...currentState.messages, Message(
          content: event.message,
          isAI: true,
          audioBuffer: event.audioBuffer
        )],
        isLoading: false,
      ));
      _logger.i('Updated conversation with AI response');
    } else {
      _logger.w('Received message while not in conversation state');
    }
  }

  void _onEndRoleplay(EndRoleplay event, Emitter<SpeakWithAIState> emit) {
    _logger.i('Ending roleplay');
    if (state is SpeakWithAIConversation) {
      _repository.closeWebSocket();
      emit(SpeakWithAIEnded(feedback: event.feedback));
    } else {
      _logger.w('Attempted to end roleplay while not in conversation state');
    }
  }

  Future<void> _reconnectWebSocket() async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        if (_lastKnownWsUrl == null || _userId == null || (state is! SpeakWithAIConversation)) {
          _logger.e('Missing information for WebSocket reconnection');
          break;
        }
        final conversationId = (state as SpeakWithAIConversation).conversationId;
        await _repository.connectWebSocket(_lastKnownWsUrl!, _userId!, conversationId);
        _listenToWebSocket();
        _logger.i('WebSocket reconnected successfully');
        return;
      } catch (e) {
        _logger.e('Failed to reconnect WebSocket: $e');
        attempts++;
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
    _logger.e('Failed to reconnect WebSocket after 3 attempts');
    emit(SpeakWithAIError('Failed to reconnect to the server. Please try again later.'));
  }

  @override
  Future<void> close() {
    _logger.i('Closing SpeakWithAIBloc');
    _wsSubscription?.cancel();
    _repository.closeWebSocket();
    return super.close();
  }
}