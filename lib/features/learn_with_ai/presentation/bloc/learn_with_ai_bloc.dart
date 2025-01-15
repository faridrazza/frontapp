import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/features/learn_with_ai/domain/models/chat_message.dart';
import 'package:logger/logger.dart';

// Events
abstract class LearnWithAiEvent extends Equatable {
  const LearnWithAiEvent();

  @override
  List<Object> get props => [];
}

class SendMessage extends LearnWithAiEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object> get props => [message];
}

// States
abstract class LearnWithAiState extends Equatable {
  const LearnWithAiState();
  
  @override
  List<Object> get props => [];
}

class LearnWithAiInitial extends LearnWithAiState {}

class LearnWithAiLoading extends LearnWithAiState {}

class LearnWithAiLoaded extends LearnWithAiState {
  final List<ChatMessage> messages;

  const LearnWithAiLoaded(this.messages);

  @override
  List<Object> get props => [messages];
}

class LearnWithAiError extends LearnWithAiState {
  final String error;

  const LearnWithAiError(this.error);

  @override
  List<Object> get props => [error];
}

// Bloc
class LearnWithAiBloc extends Bloc<LearnWithAiEvent, LearnWithAiState> {
  final ApiService _apiService;
  final Logger _logger = Logger();

  LearnWithAiBloc(this._apiService) : super(LearnWithAiLoaded([
    ChatMessage(text: "Hello, I am Musk AI. How can I assist you?", isUser: false)
  ])) {
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<LearnWithAiState> emit) async {
    try {
      _logger.i('Sending message: ${event.message}');
      final currentState = state;
      if (currentState is LearnWithAiLoaded) {
        final updatedMessages = List<ChatMessage>.from(currentState.messages)
          ..add(ChatMessage(text: event.message, isUser: true));
        emit(LearnWithAiLoaded(updatedMessages));

        final response = await _apiService.sendMessageToAI(event.message);
        final aiResponse = response['response'] as String; // Changed from 'message' to 'response'
        _logger.i('Received AI response: $aiResponse');
        
        final newMessages = List<ChatMessage>.from(updatedMessages)
          ..add(ChatMessage(text: aiResponse, isUser: false));
        emit(LearnWithAiLoaded(newMessages));
      } else {
        emit(LearnWithAiLoaded([
          ChatMessage(text: event.message, isUser: true),
        ]));

        final response = await _apiService.sendMessageToAI(event.message);
        final aiResponse = response['response'] as String; // Changed from 'message' to 'response'
        _logger.i('Received AI response: $aiResponse');
        
        emit(LearnWithAiLoaded([
          ChatMessage(text: event.message, isUser: true),
          ChatMessage(text: aiResponse, isUser: false),
        ]));
      }
    } catch (e) {
      _logger.e('Error in LearnWithAiBloc: $e');
      emit(LearnWithAiError('Failed to send message: $e'));
    }
  }
}