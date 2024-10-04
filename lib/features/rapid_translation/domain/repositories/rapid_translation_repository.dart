import '../../../../core/services/api_service.dart';
import '../models/game_session.dart';
import '../models/translation_item.dart';
import 'package:logger/logger.dart';

class RapidTranslationRepository {
  final ApiService _apiService;
  final Logger _logger = Logger();

  RapidTranslationRepository(this._apiService);

  Future<GameSession> startGame(String level, String? timer) async {
    final data = await _apiService.startTranslationGame(level, timer);
    return GameSession.fromJson(data);
  }

  Future<TranslationItem> getNextSentence(String gameSessionId) async {
    try {
      _logger.i('Fetching next sentence from repository for gameSessionId: $gameSessionId');
      final data = await _apiService.getNextSentence(gameSessionId);
      _logger.i('Received data from API: $data');
      return TranslationItem(englishSentence: data['sentence']);
    } catch (e) {
      _logger.e('Failed to get next sentence: $e');
      throw Exception('Failed to get next sentence: $e');
    }
  }

  Future<TranslationItem> submitTranslation(String gameSessionId, String translation, int timeTaken) async {
    final data = await _apiService.submitTranslation(gameSessionId, translation, timeTaken);
    return TranslationItem(
      englishSentence: data['englishSentence'],
      userTranslation: translation,
      correctTranslation: data['isCorrect'] ? null : data['correctTranslation'],
      isCorrect: data['isCorrect'],
    );
  }

  Future<void> timeUp(String gameSessionId) async {
    await _apiService.timeUp(gameSessionId);
  }

  Future<Map<String, dynamic>> endGame(String gameSessionId) async {
    return await _apiService.endTranslationGame(gameSessionId);
  }
}
