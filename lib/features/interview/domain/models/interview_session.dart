import 'interview_message.dart';

class InterviewSession {
  final String sessionId;
  final String role;
  final String experienceLevel;
  final List<InterviewMessage> messages;
  final bool isCompleted;

  InterviewSession({
    required this.sessionId,
    required this.role,
    required this.experienceLevel,
    required this.messages,
    this.isCompleted = false,
  });

  InterviewSession copyWith({
    String? sessionId,
    String? role,
    String? experienceLevel,
    List<InterviewMessage>? messages,
    bool? isCompleted,
  }) {
    return InterviewSession(
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      messages: messages ?? this.messages,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
