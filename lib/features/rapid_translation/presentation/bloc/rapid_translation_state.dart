import 'package:equatable/equatable.dart';
import '../../domain/models/game_session.dart';
import '../../domain/models/translation_item.dart';

abstract class RapidTranslationState extends Equatable {
  const RapidTranslationState();

  @override
  List<Object?> get props => [];
}

class RapidTranslationInitial extends RapidTranslationState {}

class GameStarted extends RapidTranslationState {
  final GameSession gameSession;

  const GameStarted(this.gameSession);

  @override
  List<Object> get props => [gameSession];
}

class NewSentenceReceived extends RapidTranslationState {
  final TranslationItem translationItem;

  const NewSentenceReceived(this.translationItem);

  @override
  List<Object> get props => [translationItem];
}

class TranslationSubmitted extends RapidTranslationState {
  final TranslationItem translationItem;

  const TranslationSubmitted(this.translationItem);

  @override
  List<Object> get props => [translationItem];
}

class GameEnded extends RapidTranslationState {
  final int finalScore;
  final String feedback;

  const GameEnded({required this.finalScore, required this.feedback});

  @override
  List<Object> get props => [finalScore, feedback];
}

class RapidTranslationError extends RapidTranslationState {
  final String message;

  const RapidTranslationError(this.message);

  @override
  List<Object> get props => [message];
}