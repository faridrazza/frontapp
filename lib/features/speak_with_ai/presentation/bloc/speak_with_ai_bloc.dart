import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/speak_with_ai_repository.dart';
import 'speak_with_ai_event.dart';
import 'speak_with_ai_state.dart';
import '../../domain/models/message.dart';
import 'dart:async';
import 'package:logger/logger.dart';

class SpeakWithAIBloc extends Bloc<SpeakWithAIEvent, SpeakWithAIState> {
  final SpeakWithAIRepository _repository;
  StreamSubscription? _wsSubscription;
  final Logger _logger = Logger();
  String? _lastKnownWsUrl;  // Add this line

  SpeakWithAIBloc(this._repository) : super(SpeakWithAIInitial()) {
    on<StartRoleplay>(_onStartRoleplay);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<EndRoleplay>(_onEndRoleplay);
  }

  void _onStartRoleplay(StartRoleplay event, Emitter<SpeakWithAIState> emit) async {
    _logger.i('Starting roleplay with scenario: ${event.scenario}');
    emit(SpeakWithAILoading());
    try {
      final response = await _repository.startRoleplay(event.scenario);
      _logger.i('Roleplay started. Connecting to WebSocket: ${response['wsUrl']}');
      _lastKnownWsUrl = response['wsUrl'];  // Add this line
      await _repository.connectWebSocket(_lastKnownWsUrl!);
      _listenToWebSocket();
      emit(SpeakWithAIConversation(
        conversationId: response['conversationId'],
        messages: [Message(content: response['initialPrompt'], type: MessageType.ai, audioBuffer: response['audioBuffer'])],
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
        if (data['intent'] == 'end_roleplay') {
          add(EndRoleplay(data['feedback']));
        } else {
          add(ReceiveMessage(data['aiResponse'], data['audioBuffer']));
        }
      },
      onError: (error) {
        _logger.e('WebSocket error: $error');
        add(ReceiveMessage(error.toString(), null));
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
      emit(currentState.copyWith(
        messages: [...currentState.messages, Message(content: event.message, type: MessageType.user)],
        isLoading: true,
      ));
      _repository.sendMessage(currentState.conversationId, event.message);
      _logger.i('Message sent, waiting for AI response');
      
      // Add timeout
      await Future.delayed(Duration(seconds: 30));
      if (state is SpeakWithAIConversation && (state as SpeakWithAIConversation).isLoading) {
        _logger.w('AI response timeout');
        emit((state as SpeakWithAIConversation).copyWith(isLoading: false));
        add(ReceiveMessage('AI response timeout. Please try again.', null));
      }
    } else {
      _logger.w('Attempted to send message while not in conversation state');
    }
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<SpeakWithAIState> emit) {
    _logger.i('Received AI message: ${event.message}');
    if (state is SpeakWithAIConversation) {
      final currentState = state as SpeakWithAIConversation;
      emit(currentState.copyWith(
        messages: [...currentState.messages, Message(content: event.message, type: MessageType.ai, audioBuffer: event.audioBuffer)],
        isLoading: false,
      ));
      _logger.i('Updated conversation with AI response');
    } else {
      _logger.w('Received message while not in conversation state');
    }
  }

  void _onEndRoleplay(EndRoleplay event, Emitter<SpeakWithAIState> emit) {
    _logger.i('Ending roleplay');
    _repository.closeWebSocket();
    emit(SpeakWithAIEnded(feedback: event.feedback));
  }

  Future<void> _reconnectWebSocket() async {
    int attempts = 0;
    while (attempts < 3) {
      try {
        if (_lastKnownWsUrl == null) {
          _logger.e('No known WebSocket URL to reconnect to');
          break;
        }
        await _repository.connectWebSocket(_lastKnownWsUrl!);
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