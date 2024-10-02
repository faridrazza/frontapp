import 'package:equatable/equatable.dart';

abstract class RapidTranslationEvent extends Equatable {
  const RapidTranslationEvent();

  @override
  List<Object?> get props => [];
}

class StartGame extends RapidTranslationEvent {
  final String level;
  final String? timer;

  const StartGame({required this.level, this.timer});

  @override
  List<Object?> get props => [level, timer];
}

class GetNextSentence extends RapidTranslationEvent {}

class SubmitTranslation extends RapidTranslationEvent {
  final String translation;
  final int timeTaken;

  const SubmitTranslation({required this.translation, required this.timeTaken});

  @override
  List<Object> get props => [translation, timeTaken];
}

class TimeUp extends RapidTranslationEvent {}

class EndGame extends RapidTranslationEvent {}
