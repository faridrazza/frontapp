import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/speak_with_ai_repository.dart';
import 'speak_with_ai_event.dart';
import 'speak_with_ai_state.dart';
import '../../domain/models/message.dart';

class SpeakWithAIBloc extends Bloc<SpeakWithAIEvent, SpeakWithAIState> {
  final SpeakWithAIRepository _repository;

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
      emit(SpeakWithAIConversation(
        conversationId: response['conversationId'],
        messages: [Message(content: response['initialPrompt'], type: MessageType.ai, audioBuffer: response['audioBuffer'])],
      ));
    } catch (e) {
      emit(SpeakWithAIError(e.toString()));
    }
  }

  void _onSendMessage(SendMessage event, Emitter<SpeakWithAIState> emit) {
    if (state is SpeakWithAIConversation) {
      final currentState = state as SpeakWithAIConversation;
      _repository.sendMessage(currentState.conversationId, event.message);
      emit(currentState.copyWith(
        messages: [...currentState.messages, Message(content: event.message, type: MessageType.user)],
      ));
    }
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<SpeakWithAIState> emit) {
    if (state is SpeakWithAIConversation) {
      final currentState = state as SpeakWithAIConversation;
      emit(currentState.copyWith(
        messages: [...currentState.messages, Message(content: event.message, type: MessageType.ai, audioBuffer: event.audioBuffer)],
      ));
    }
  }

  void _onEndRoleplay(EndRoleplay event, Emitter<SpeakWithAIState> emit) {
    _repository.closeWebSocket();
    emit(SpeakWithAIEnded(feedback: event.feedback));
  }
}