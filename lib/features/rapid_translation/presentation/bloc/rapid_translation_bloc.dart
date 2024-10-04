import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/rapid_translation_repository.dart';
import 'rapid_translation_event.dart';
import 'rapid_translation_state.dart';
import 'package:logger/logger.dart';

class RapidTranslationBloc extends Bloc<RapidTranslationEvent, RapidTranslationState> {
  final RapidTranslationRepository repository;
  final Logger _logger = Logger();
  String? gameSessionId;
  int score = 0;

  RapidTranslationBloc(this.repository) : super(RapidTranslationInitial()) {
    on<StartGame>(_onStartGame);
    on<GetNextSentence>(_onGetNextSentence);
    on<SubmitTranslation>(_onSubmitTranslation);
    on<TimeUp>(_onTimeUp);
    on<EndGame>(_onEndGame);
  }

  void _onStartGame(StartGame event, Emitter<RapidTranslationState> emit) async {
    try {
      _logger.i('Starting game with level: ${event.level}, timer: ${event.timer}');
      final gameSession = await repository.startGame(event.level, event.timer);
      gameSessionId = gameSession.id;
      emit(GameStarted(gameSession));
      _logger.i('Game started. Fetching first sentence.');
      add(GetNextSentence());
    } catch (e) {
      _logger.e('Error starting game: $e');
      emit(RapidTranslationError(e.toString()));
    }
  }

  void _onGetNextSentence(GetNextSentence event, Emitter<RapidTranslationState> emit) async {
    if (gameSessionId == null) {
      _logger.e('Attempted to get next sentence without starting the game');
      emit(RapidTranslationError('Game not started. Please start the game first.'));
      return;
    }

    try {
      _logger.i('Getting next sentence for gameSessionId: $gameSessionId');
      final translationItem = await repository.getNextSentence(gameSessionId!);
      _logger.i('Received translation item: $translationItem');
      if (translationItem.englishSentence.isEmpty) {
        _logger.e('Received empty sentence');
        emit(RapidTranslationError('Received empty sentence from server'));
      } else {
        emit(NewSentenceReceived(translationItem));
        _logger.i('Emitted NewSentenceReceived state');
      }
    } catch (e) {
      _logger.e('Error getting next sentence: $e');
      emit(RapidTranslationError(e.toString()));
    }
  }

  void _onSubmitTranslation(SubmitTranslation event, Emitter<RapidTranslationState> emit) async {
    try {
      final result = await repository.submitTranslation(gameSessionId!, event.translation, event.timeTaken);
      if (result.isCorrect!) {
        score++;
      }
      emit(TranslationSubmitted(result));
      add(GetNextSentence());
    } catch (e) {
      emit(RapidTranslationError(e.toString()));
    }
  }

  void _onTimeUp(TimeUp event, Emitter<RapidTranslationState> emit) async {
    try {
      await repository.timeUp(gameSessionId!);
      add(GetNextSentence());
    } catch (e) {
      emit(RapidTranslationError(e.toString()));
    }
  }

  void _onEndGame(EndGame event, Emitter<RapidTranslationState> emit) async {
    try {
      final result = await repository.endGame(gameSessionId!);
      emit(GameEnded(finalScore: score, feedback: result['feedback']));
    } catch (e) {
      emit(RapidTranslationError(e.toString()));
    }
  }
}