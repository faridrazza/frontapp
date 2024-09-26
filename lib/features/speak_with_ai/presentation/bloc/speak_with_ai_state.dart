import 'package:equatable/equatable.dart';
import '../../domain/models/message.dart';

abstract class SpeakWithAIState extends Equatable {
  const SpeakWithAIState();

  @override
  List<Object> get props => [];
}

class SpeakWithAIInitial extends SpeakWithAIState {}

class SpeakWithAILoading extends SpeakWithAIState {}

class SpeakWithAIConversation extends SpeakWithAIState {
  final String conversationId;
  final List<Message> messages;

  const SpeakWithAIConversation({
    required this.conversationId,
    required this.messages,
  });

  SpeakWithAIConversation copyWith({
    String? conversationId,
    List<Message>? messages,
  }) {
    return SpeakWithAIConversation(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object> get props => [conversationId, messages];
}

class SpeakWithAIEnded extends SpeakWithAIState {
  final Map<String, dynamic> feedback;

  const SpeakWithAIEnded({required this.feedback});

  @override
  List<Object> get props => [feedback];
}

class SpeakWithAIError extends SpeakWithAIState {
  final String message;

  const SpeakWithAIError(this.message);

  @override
  List<Object> get props => [message];
}