import 'package:equatable/equatable.dart';
import '../../domain/models/message.dart';
import '../../domain/models/roleplay_feedback.dart';

abstract class SpeakWithAIState extends Equatable {
  const SpeakWithAIState();

  @override
  List<Object?> get props => [];
}

class SpeakWithAIInitial extends SpeakWithAIState {}

class SpeakWithAILoading extends SpeakWithAIState {}

class SpeakWithAIConversation extends SpeakWithAIState {
  final String conversationId;
  final List<Message> messages;
  final bool isLoading;

  const SpeakWithAIConversation({
    required this.conversationId,
    required this.messages,
    this.isLoading = false,
  });

  SpeakWithAIConversation copyWith({
    String? conversationId,
    List<Message>? messages,
    bool? isLoading,
  }) {
    return SpeakWithAIConversation(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [conversationId, messages, isLoading];
}

class SpeakWithAIEnded extends SpeakWithAIState {
  final RoleplayFeedback feedback;

  const SpeakWithAIEnded({required this.feedback});

  @override
  List<Object?> get props => [feedback];
}

class SpeakWithAIError extends SpeakWithAIState {
  final String message;

  const SpeakWithAIError(this.message);

  @override
  List<Object> get props => [message];
}