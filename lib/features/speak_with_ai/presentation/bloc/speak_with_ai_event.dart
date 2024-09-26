import 'package:equatable/equatable.dart';

abstract class SpeakWithAIEvent extends Equatable {
  const SpeakWithAIEvent();

  @override
  List<Object> get props => [];
}

class StartRoleplay extends SpeakWithAIEvent {
  final String scenario;

  const StartRoleplay(this.scenario);

  @override
  List<Object> get props => [scenario];
}

class SendMessage extends SpeakWithAIEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object> get props => [message];
}

class ReceiveMessage extends SpeakWithAIEvent {
  final String message;
  final String? audioBuffer;

  const ReceiveMessage(this.message, this.audioBuffer);

  @override
  List<Object> get props => [message, if (audioBuffer != null) audioBuffer!];
}

class EndRoleplay extends SpeakWithAIEvent {
  final Map<String, dynamic> feedback;

  const EndRoleplay(this.feedback);

  @override
  List<Object> get props => [feedback];
}