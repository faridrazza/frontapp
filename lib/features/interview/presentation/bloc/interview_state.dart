import 'package:equatable/equatable.dart';
import '../../domain/models/interview_session.dart';
import '../../domain/models/interview_message.dart';
import '../../domain/models/interview_feedback.dart';

abstract class InterviewState extends Equatable {
  const InterviewState();

  @override
  List<Object?> get props => [];
}

class InterviewInitial extends InterviewState {}

class InterviewLoading extends InterviewState {}

class InterviewInProgress extends InterviewState {
  final InterviewSession session;
  final bool isProcessing;

  const InterviewInProgress({
    required this.session,
    this.isProcessing = false,
  });

  InterviewInProgress copyWith({
    InterviewSession? session,
    bool? isProcessing,
  }) {
    return InterviewInProgress(
      session: session ?? this.session,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [session, isProcessing];
}

class InterviewCompleted extends InterviewState {
  final InterviewFeedback feedback;
  final InterviewSession session;

  const InterviewCompleted({
    required this.feedback,
    required this.session,
  });

  @override
  List<Object> get props => [feedback, session];
}

class InterviewError extends InterviewState {
  final String message;

  const InterviewError(this.message);

  @override
  List<Object> get props => [message];
}
