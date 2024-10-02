import '../../../../core/services/api_service.dart';
import '../models/game_session.dart';
import '../models/translation_item.dart';

class RapidTranslationRepository {
  final ApiService _apiService;

  RapidTranslationRepository(this._apiService);

  Future<GameSession> startGame(String level, String? timer) async {
    final data = await _apiService.startTranslationGame(level, timer);
    return GameSession.fromJson(data);
  }

  Future<TranslationItem> getNextSentence(String gameSessionId) async {
    final data = await _apiService.getNextSentence(gameSessionId);
    return TranslationItem(englishSentence: data['sentence']);
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
