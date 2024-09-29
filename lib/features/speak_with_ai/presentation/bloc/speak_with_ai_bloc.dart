import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/speak_with_ai_repository.dart';
import 'speak_with_ai_event.dart';
import 'speak_with_ai_state.dart';
import '../../domain/models/message.dart';
import 'dart:async';

class SpeakWithAIBloc extends Bloc<SpeakWithAIEvent, SpeakWithAIState> {
  final SpeakWithAIRepository _repository;
  StreamSubscription? _wsSubscription;

  SpeakWithAIBloc(this._repository) : super(SpeakWithAIInitial()) {
    on<StartRoleplay>(_onStartRoleplay);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<EndRoleplay>(_onEndRoleplay);
  }

  void _onStartRoleplay(StartRoleplay event, Emitter<SpeakWithAIState> emit) async {
    emit(SpeakWithAILoading());
    try {
      final response = await _repository.startRoleplay(event.scenario);
      await _repository.connectWebSocket(response['wsUrl']);
      _listenToWebSocket();
      emit(SpeakWithAIConversation(
        conversationId: response['conversationId'],
        messages: [Message(content: response['initialPrompt'], type: MessageType.ai, audioBuffer: response['audioBuffer'])],
      ));
    } catch (e) {
      emit(SpeakWithAIError(e.toString()));
    }
  }

  void _listenToWebSocket() {
    _wsSubscription = _repository.aiResponses.listen((data) {
      if (data['intent'] == 'end_roleplay') {
        add(EndRoleplay(data['feedback']));
      } else {
        add(ReceiveMessage(data['aiResponse'], data['audioBuffer']));
      }
    });
  }

  void _onSendMessage(SendMessage event, Emitter<SpeakWithAIState> emit) {
    if (state is SpeakWithAIConversation) {
      final currentState = state as SpeakWithAIConversation;
      _repository.sendMessage(currentState.conversationId, event.message);
      emit(currentState.copyWith(
        messages: [...currentState.messages, Message(content: event.message, type: MessageType.user)],
        isLoading: true, // Set loading to true while waiting for AI response
      ));
    }
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<SpeakWithAIState> emit) {
    if (state is SpeakWithAIConversation) {
      final currentState = state as SpeakWithAIConversation;
      emit(currentState.copyWith(
        messages: [...currentState.messages, Message(content: event.message, type: MessageType.ai, audioBuffer: event.audioBuffer)],
        isLoading: false, // Set loading to false when AI response is received
      ));
    }
  }

  void _onEndRoleplay(EndRoleplay event, Emitter<SpeakWithAIState> emit) {
    _repository.closeWebSocket();
    emit(SpeakWithAIEnded(feedback: event.feedback));
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    _repository.closeWebSocket();
    return super.close();
  }
}