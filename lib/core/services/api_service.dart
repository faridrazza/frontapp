import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:frontapp/core/config/app_config.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Logger _logger = Logger();

  // // Use this for local development
  // static const String _baseUrlDev = 'http://192.168.0.105:5000'; // Verify this IP and port
  // Use this for production (replace with your actual production URL when ready)
  // static const String _baseUrlProd = 'https://your-deployed-backend.com';

  // Set this to true for production, false for local development
  static const bool _isProduction = false;

  static String get _baseUrl => AppConfig.baseUrl;

  Future<Map<String, dynamic>> sendOtp(String countryCode, String phoneNumber) async {
    _logger.i('📱 Initiating OTP send request');
    _logger.d('Parameters - Country Code: $countryCode, Phone Number: $phoneNumber');

    // Ensure country code starts with '+' and is not longer than 4 characters
    if (!countryCode.startsWith('+')) {
      countryCode = '+$countryCode';
      _logger.d('Added + to country code: $countryCode');
    }
    if (countryCode.length > 4) {
      countryCode = countryCode.substring(0, 4);
      _logger.d('Trimmed country code to: $countryCode');
    }

    // Remove any non-digit characters from the phone number
    String cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    _logger.d('Cleaned phone number: $cleanPhoneNumber');

    try {
      _logger.d('Making API request to: $_baseUrl/api/auth/send-otp');
      final response = await _dio.post(
        '$_baseUrl/api/auth/send-otp',
        data: {
          'countryCode': countryCode,
          'phoneNumber': cleanPhoneNumber,
        },
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ OTP sent successfully');
        return response.data;
      } else {
        _logger.e('❌ Failed to send OTP. Status code: ${response.statusCode}');
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      _logger.e('❌ Error sending OTP', error: e);
      throw Exception('Error sending OTP: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String countryCode, String phoneNumber, String otp) async {
    _logger.i('🔐 Initiating OTP verification');
    _logger.d('Parameters - Country Code: $countryCode, Phone Number: $phoneNumber, OTP: $otp');

    try {
      _logger.d('Making API request to: $_baseUrl/api/auth/verify-otp');
      final response = await _dio.post(
        '$_baseUrl/api/auth/verify-otp',
        data: {
          'countryCode': countryCode,
          'phoneNumber': phoneNumber,
          'otp': otp,
        },
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final token = response.data['token'];
        _logger.i('✅ OTP verified successfully');
        _logger.d('Storing auth token');
        await _storage.write(key: 'auth_token', value: token);
        return response.data;
      } else {
        _logger.e('❌ Failed to verify OTP. Status code: ${response.statusCode}');
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      _logger.e('❌ Error verifying OTP', error: e);
      throw Exception('Error verifying OTP: $e');
    }
  }

  Future<Map<String, dynamic>> completeProfile(String name, String email, String nativeLanguage) async {
    _logger.i('👤 Initiating profile completion');
    _logger.d('Parameters - Name: $name, Email: $email, Native Language: $nativeLanguage');

    try {
      final token = await _storage.read(key: 'auth_token');
      _logger.d('Retrieved auth token: ${token?.substring(0, 10)}...');

      _logger.d('Making API request to: $_baseUrl/api/auth/complete-profile');
      final response = await _dio.post(
        '$_baseUrl/api/auth/complete-profile',
        data: {
          'name': name,
          'email': email,
          'nativeLanguage': nativeLanguage,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ Profile completed successfully');
        return response.data;
      } else {
        _logger.e('❌ Failed to complete profile. Status code: ${response.statusCode}');
        throw Exception('Failed to complete profile');
      }
    } catch (e) {
      _logger.e('❌ Error completing profile', error: e);
      throw Exception('Error completing profile: $e');
    }
  }

  Future<void> resendOtp(String countryCode, String phoneNumber) async {
    try {
      final response = await _dio.post('$_baseUrl/api/auth/resend-otp', data: {
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
      });

      if (response.statusCode != 200) {
        throw Exception('Failed to resend OTP');
      }
    } catch (e) {
      throw Exception('Error resending OTP: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '$_baseUrl/api/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<Map<String, dynamic>> startRoleplay(String scenario) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      print('Starting roleplay with scenario: $scenario');
      print('Using base URL: $_baseUrl');
      final response = await _dio.post(
        '$_baseUrl/api/ai-speak/start-roleplay',
        data: {'scenario': scenario},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Response received: ${response.statusCode}');
      if (response.statusCode == 200) {
        // Assuming the backend now includes userId in the response
        return {
          'conversationId': response.data['conversationId'],
          'initialPrompt': response.data['initialPrompt'],
          'audioBuffer': response.data['audioBuffer'],
          'wsUrl': response.data['wsUrl'],
          'userId': response.data['userId'], // Add this line
        };
      } else {
        throw Exception('Failed to start roleplay');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('Error starting roleplay: $e');
    }
  }

  Future<Map<String, dynamic>> startTranslationGame(String level, String? timer) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/ai/start-translation',
        data: {
          'gameLevel': level,
          'timer': timer,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to start game');
      }
    } catch (e) {
      throw Exception('Error starting game: $e');
    }
  }

  Future<Map<String, dynamic>> getNextSentence(String gameSessionId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      _logger.i('Fetching next sentence for gameSessionId: $gameSessionId');
      final response = await _dio.post(
        '$_baseUrl/api/ai/get-next-sentence',
        data: {'gameSessionId': gameSessionId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _logger.i('Received next sentence: ${response.data}');
        return response.data;
      } else {
        _logger.e('Failed to get next sentence. Status code: ${response.statusCode}');
        throw Exception('Failed to get next sentence');
      }
    } catch (e) {
      _logger.e('Error getting next sentence: $e');
      throw Exception('Error getting next sentence: $e');
    }
  }

  Future<Map<String, dynamic>> submitTranslation(String gameSessionId, String translation, int timeTaken) async {
    _logger.i('Submitting translation: gameSessionId=$gameSessionId, translation=$translation, timeTaken=$timeTaken');
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/ai/submit-translation',
        data: {
          'gameSessionId': gameSessionId,
          'translation': translation,
          'timeTaken': timeTaken,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      _logger.d('API response: ${response.data}');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        _logger.e('Failed to submit translation: ${response.statusCode}');
        throw Exception('Failed to submit translation');
      }
    } catch (e) {
      _logger.e('Error submitting translation: $e');
      throw Exception('Error submitting translation: $e');
    }
  }

  Future<Map<String, dynamic>> timeUp(String gameSessionId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/ai/time-up',
        data: {'gameSessionId': gameSessionId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to handle time up');
      }
    } catch (e) {
      throw Exception('Error handling time up: $e');
    }
  }

  Future<Map<String, dynamic>> endTranslationGame(String gameSessionId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/ai/end-translation-game',
        data: {'gameSessionId': gameSessionId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to end game');
      }
    } catch (e) {
      throw Exception('Error ending game: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfile({String? name, String? phoneNumber, String? nativeLanguage}) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.put(
        '$_baseUrl/api/user/profile',
        data: {
          if (name != null) 'name': name,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (nativeLanguage != null) 'nativeLanguage': nativeLanguage,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  Future<void> submitReport({required String email, required String subject, required String message}) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/submit-report',
        data: {
          'email': email,
          'subject': subject,
          'message': message,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to submit report');
      }
    } catch (e) {
      throw Exception('Error submitting report: $e');
    }
  }

  Future<void> submitCustomerSupport({required String name, required String email, required String message}) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/customer-support',
        data: {
          'name': name,
          'email': email,
          'message': message,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to submit customer support request');
      }
    } catch (e) {
      throw Exception('Error submitting customer support request: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessageToAI(String message) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      _logger.i('Sending message to AI: $message');
      final response = await _dio.post(
        '$_baseUrl/api/ai/chat',
        data: {'message': message},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        _logger.i('Received response from AI: ${response.data}');
        return response.data;
      } else {
        _logger.e('Failed to send message to AI. Status code: ${response.statusCode}');
        throw Exception('Failed to send message to AI');
      }
    } catch (e) {
      _logger.e('Error sending message to AI: $e');
      throw Exception('Error sending message to AI: $e');
    }
  }
}
