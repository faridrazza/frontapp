import 'package:equatable/equatable.dart';
import '../../domain/models/interview_feedback.dart';

abstract class InterviewEvent extends Equatable {
  const InterviewEvent();

  @override
  List<Object?> get props => [];
}

class StartInterview extends InterviewEvent {
  final String role;
  final String experienceLevel;

  const StartInterview({
    required this.role,
    required this.experienceLevel,
  });

  @override
  List<Object> get props => [role, experienceLevel];
}

class SendResponse extends InterviewEvent {
  final String response;

  const SendResponse(this.response);

  @override
  List<Object> get props => [response];
}

class EndInterview extends InterviewEvent {}

class ResetInterview extends InterviewEvent {}
