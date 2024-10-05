import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontapp/core/services/api_service.dart';

// Events
abstract class RapidTranslationEvent extends Equatable {
  const RapidTranslationEvent();

  @override
  List<Object> get props => [];
}

class StartGame extends RapidTranslationEvent {
  final String difficulty;
  final String timer;

  const StartGame({required this.difficulty, required this.timer});

  @override
  List<Object> get props => [difficulty, timer];
}

class SubmitTranslation extends RapidTranslationEvent {
  final String translation;
  final int timeTaken;

  const SubmitTranslation({required this.translation, required this.timeTaken});

  @override
  List<Object> get props => [translation, timeTaken];
}

class GetNextSentence extends RapidTranslationEvent {}

class EndGame extends RapidTranslationEvent {}

// States
abstract class RapidTranslationState extends Equatable {
  const RapidTranslationState();
  
  @override
  List<Object> get props => [];
}

class RapidTranslationInitial extends RapidTranslationState {}

class GameStarted extends RapidTranslationState {
  final String gameSessionId;
  final String sentence;

  const GameStarted({required this.gameSessionId, required this.sentence});

  @override
  List<Object> get props => [gameSessionId, sentence];
}

class TranslationSubmitted extends RapidTranslationState {
  final bool isCorrect;
  final String correctTranslation;

  const TranslationSubmitted({
    required this.isCorrect,
    required this.correctTranslation,
  });

  @override
  List<Object> get props => [isCorrect, correctTranslation];
}

class NewSentenceReceived extends RapidTranslationState {
  final String sentence;

  const NewSentenceReceived({required this.sentence});

  @override
  List<Object> get props => [sentence];
}

class GameEnded extends RapidTranslationState {}

class RapidTranslationError extends RapidTranslationState {
  final String message;

  const RapidTranslationError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class RapidTranslationBloc extends Bloc<RapidTranslationEvent, RapidTranslationState> {
  final ApiService _apiService;
  String _gameSessionId = '';

  RapidTranslationBloc(this._apiService) : super(RapidTranslationInitial()) {
    on<StartGame>(_onStartGame);
    on<SubmitTranslation>(_onSubmitTranslation);
    on<GetNextSentence>(_onGetNextSentence);
    on<EndGame>(_onEndGame);
  }

  Future<void> _onStartGame(StartGame event, Emitter<RapidTranslationState> emit) async {
    try {
      final result = await _apiService.startTranslationGame(event.difficulty, event.timer);
      _gameSessionId = result['gameSessionId'];
      emit(GameStarted(gameSessionId: _gameSessionId, sentence: result['initialSentence']));
    } catch (e) {
      emit(RapidTranslationError(message: 'Failed to start game: $e'));
    }
  }

  Future<void> _onSubmitTranslation(SubmitTranslation event, Emitter<RapidTranslationState> emit) async {
    try {
      final result = await _apiService.submitTranslation(_gameSessionId, event.translation, event.timeTaken);
      emit(TranslationSubmitted(
        isCorrect: result['isCorrect'],
        correctTranslation: result['correctTranslation'],
      ));
    } catch (e) {
      emit(RapidTranslationError(message: 'Failed to submit translation: $e'));
    }
  }

  Future<void> _onGetNextSentence(GetNextSentence event, Emitter<RapidTranslationState> emit) async {
    try {
      final result = await _apiService.getNextSentence(_gameSessionId);
      emit(NewSentenceReceived(sentence: result['sentence']));
    } catch (e) {
      emit(RapidTranslationError(message: 'Failed to get next sentence: $e'));
    }
  }

  Future<void> _onEndGame(EndGame event, Emitter<RapidTranslationState> emit) async {
    try {
      await _apiService.endTranslationGame(_gameSessionId);
      emit(GameEnded());
    } catch (e) {
      emit(RapidTranslationError(message: 'Failed to end game: $e'));
    }
  }
}