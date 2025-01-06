import 'package:frontapp/core/services/api_service.dart';
import '../models/interview_feedback.dart';
import 'package:logger/logger.dart';

class InterviewRepository {
  final ApiService _apiService;
  final Logger _logger = Logger();

  InterviewRepository(this._apiService);

  Future<Map<String, dynamic>> startInterview(String role, String experienceLevel) async {
    _logger.i('Starting interview with role: $role, experienceLevel: $experienceLevel');
    try {
      final response = await _apiService.startInterview(role, experienceLevel);
      _logger.i('Interview started successfully');
      return response;
    } catch (e) {
      _logger.e('Error starting interview: $e');
      throw Exception('Failed to start interview: $e');
    }
  }

  Future<Map<String, dynamic>> sendResponse(String sessionId, String response) async {
    _logger.i('Sending response for session: $sessionId');
    try {
      final aiResponse = await _apiService.sendInterviewResponse(sessionId, response);
      _logger.i('Response sent successfully');
      return aiResponse;
    } catch (e) {
      _logger.e('Error sending response: $e');
      throw Exception('Failed to send response: $e');
    }
  }

  Future<InterviewFeedback> endInterview(String sessionId) async {
    _logger.i('Ending interview session: $sessionId');
    try {
      final response = await _apiService.endInterview(sessionId);
      _logger.i('Interview ended successfully');
      return InterviewFeedback.fromJson(response['feedback']);
    } catch (e) {
      _logger.e('Error ending interview: $e');
      throw Exception('Failed to end interview: $e');
    }
  }
}
