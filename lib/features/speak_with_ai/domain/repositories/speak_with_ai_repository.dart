import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/core/services/websocket_service.dart';
import '../models/conversation.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

class SpeakWithAIRepository {
  final ApiService _apiService;
  final WebSocketService _webSocketService;
  final Logger _logger = Logger();

  SpeakWithAIRepository(this._apiService, this._webSocketService);

  Future<Map<String, dynamic>> startRoleplay(String scenario) async {
    _logger.i('Starting roleplay with scenario: $scenario');
    final response = await _apiService.startRoleplay(scenario);
    _logger.i('Roleplay started. Response: $response');
    return response;
  }

  Future<void> connectWebSocket(String wsUrl, String userId, String conversationId) async {
    final url = '$wsUrl?userId=$userId&conversationId=$conversationId';
    _logger.i('Connecting to WebSocket: $url');
    await _webSocketService.connect(url);
    _logger.i('WebSocket connected');
  }

  void sendMessage(String conversationId, String message) {
    _logger.i('Sending message to WebSocket. ConversationId: $conversationId, Message: $message');
    _webSocketService.send(jsonEncode({
      'conversationId': conversationId,
      'userMessage': message,
    }));
  }

  Stream<dynamic> get aiResponses => _webSocketService.stream.map((event) {
        _logger.i('Received WebSocket message: $event');
        return event;
      });

  void closeWebSocket() {
    _logger.i('Closing WebSocket');
    _webSocketService.close();
  }

  bool isWebSocketConnected() {
    return _webSocketService.isConnected();
  }
}