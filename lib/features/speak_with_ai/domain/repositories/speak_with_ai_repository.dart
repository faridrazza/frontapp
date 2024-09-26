import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/core/services/websocket_service.dart';
import '../models/conversation.dart';
import 'dart:convert';

class SpeakWithAIRepository {
  final ApiService _apiService;
  final WebSocketService _webSocketService;

  SpeakWithAIRepository(this._apiService, this._webSocketService);

  Future<Map<String, dynamic>> startRoleplay(String scenario) async {
    return await _apiService.startRoleplay(scenario);
  }

  Future<void> connectWebSocket(String url) async {
    await _webSocketService.connect(url);
  }

  void sendMessage(String conversationId, String message) {
    _webSocketService.send(jsonEncode({
      'conversationId': conversationId,
      'userMessage': message,
    }));
  }

  Stream<dynamic> get aiResponses => _webSocketService.stream;

  void closeWebSocket() {
    _webSocketService.close();
  }
}