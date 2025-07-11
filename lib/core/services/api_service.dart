import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:frontapp/core/config/app_config.dart';
import 'package:frontapp/core/utils/feedback_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontapp/features/script_chat/domain/models/video.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Logger _logger = Logger();
  final _supabase = Supabase.instance.client;

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
    _logger.i('👤 Initiating profile fetch');
    
    try {
      final token = await _storage.read(key: 'auth_token');
      _logger.d('Retrieved auth token: ${token?.substring(0, 10)}...'); // Only log first 10 chars of token for security
      
      _logger.d('Making API request to: $_baseUrl/api/auth/me');
      final response = await _dio.get(
        '$_baseUrl/api/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ Profile fetched successfully');
        return response.data;
      } else {
        _logger.e('❌ Failed to fetch profile. Status code: ${response.statusCode}');
        throw Exception('Failed to fetch profile');
      }
    } catch (e) {
      _logger.e('❌ Error fetching profile', error: e);
      if (e.toString().contains('401')) {
        _logger.w('⚠️ Authentication token might be expired or invalid');
      }
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

  Future<Map<String, dynamic>> startInterview(String role, String experienceLevel) async {
    _logger.i('📝 Starting interview session');
    _logger.d('Parameters - Role: $role, Experience Level: $experienceLevel');

    try {
      final token = await _storage.read(key: 'auth_token');
      _logger.d('Making API request to: $_baseUrl/api/interview/start');
      _logger.d('Request payload: { role: $role, experienceLevel: $experienceLevel }');

      final response = await _dio.post(
        '$_baseUrl/api/interview/start',
        data: {
          'role': role,
          'experienceLevel': experienceLevel,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ Interview started successfully');
        return {
          'sessionId': response.data['sessionId'],
          'message': response.data['message'],
          'audio': response.data['audio'],
        };
      } else {
        _logger.e('❌ Failed to start interview: ${response.statusCode}');
        throw Exception('Failed to start interview');
      }
    } catch (e) {
      _logger.e('❌ Error starting interview', error: e);
      throw Exception('Error starting interview: $e');
    }
  }

  Future<Map<String, dynamic>> sendInterviewResponse(String sessionId, String userResponse) async {
    _logger.i('🗣️ Sending interview response');
    _logger.d('Parameters - SessionId: $sessionId');
    _logger.d('User Response: $userResponse');

    try {
      final token = await _storage.read(key: 'auth_token');
      _logger.d('Making API request to: $_baseUrl/api/interview/respond');
      _logger.d('Request payload: { sessionId: $sessionId, userResponse: $userResponse }');

      final response = await _dio.post(
        '$_baseUrl/api/interview/respond',
        data: {
          'sessionId': sessionId,
          'userResponse': userResponse,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ Response sent successfully');
        return {
          'message': response.data['message'],
          'audio': response.data['audio'],
        };
      } else {
        _logger.e('❌ Failed to send response: ${response.statusCode}');
        throw Exception('Failed to send interview response');
      }
    } catch (e) {
      _logger.e('❌ Error sending interview response', error: e);
      throw Exception('Error sending interview response: $e');
    }
  }

  Future<Map<String, dynamic>> endInterview(String sessionId) async {
    _logger.i('🏁 Ending interview session');
    _logger.d('Parameters - SessionId: $sessionId');

    try {
      final token = await _storage.read(key: 'auth_token');
      _logger.d('Making API request to: $_baseUrl/api/interview/end');
      _logger.d('Request payload: { sessionId: $sessionId }');

      final response = await _dio.post(
        '$_baseUrl/api/interview/end',
        data: {'sessionId': sessionId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ Interview ended successfully');
        final feedbackString = response.data['feedback'];
        if (feedbackString == null) {
          _logger.e('❌ No feedback received from server');
          throw Exception('No feedback received from server');
        }
        
        _logger.d('Raw feedback string: $feedbackString');
        final parsedFeedback = FeedbackParser.parseFeedbackString(feedbackString);
        _logger.d('Parsed feedback: $parsedFeedback');
        
        return parsedFeedback;
      } else {
        _logger.e('❌ Failed to end interview: ${response.statusCode}');
        throw Exception('Failed to end interview');
      }
    } catch (e) {
      _logger.e('❌ Error ending interview', error: e);
      throw Exception('Error ending interview: $e');
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String nativeLanguage,
  }) async {
    _logger.i('📝 Initiating sign up process');
    _logger.d('Sign up parameters - Email: $email, Name: $name, Native Language: $nativeLanguage');
    
    try {
      _logger.d('Making API request to: $_baseUrl/api/auth/signup');
      _logger.d('Request payload: { email: $email, name: $name, nativeLanguage: $nativeLanguage }');

      final response = await _dio.post(
        '$_baseUrl/api/auth/signup',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'nativeLanguage': nativeLanguage,
        },
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('✅ Sign up successful');
        final token = response.data['token'];
        
        if (token != null) {
          _logger.d('Token received, storing in secure storage');
          await _storage.write(key: 'auth_token', value: token);
          _logger.d('Setting up authorization header for future requests');
          _dio.options.headers['Authorization'] = 'Bearer $token';
        } else {
          _logger.w('⚠️ No token received in sign up response');
        }
        
        return response.data;
      } else {
        _logger.e('❌ Sign up failed with status code: ${response.statusCode}');
        throw Exception('Failed to sign up');
      }
    } catch (e) {
      _logger.e('❌ Error during sign up', error: e);
      throw Exception('Error during sign up: $e');
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    _logger.i('🔐 Initiating sign in process');
    _logger.d('Sign in parameters - Email: $email');
    
    try {
      _logger.d('Making API request to: $_baseUrl/api/auth/signin');
      _logger.d('Request payload: { email: $email }');

      final response = await _dio.post(
        '$_baseUrl/api/auth/signin',
        data: {
          'email': email,
          'password': password,
        },
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ Sign in successful');
        final token = response.data['token'];
        
        if (token != null) {
          _logger.d('Token received, storing in secure storage');
          await _storage.write(key: 'auth_token', value: token);
          _logger.d('Setting up authorization header for future requests');
          _dio.options.headers['Authorization'] = 'Bearer $token';
        } else {
          _logger.w('⚠️ No token received in sign in response');
        }
        
        return response.data;
      } else {
        _logger.e('❌ Sign in failed with status code: ${response.statusCode}');
        throw Exception('Failed to sign in');
      }
    } on DioException catch (e) {
      _logger.e('❌ Error during sign in', error: e);
      
      // Handle 401 status code specifically
      if (e.response?.statusCode == 401) {
        final errorMessage = e.response?.data['message'] ?? 'Invalid email or password';
        throw Exception(errorMessage);
      }
      
      // Handle other DioExceptions
      String errorMessage = 'Error during sign in';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      throw Exception(errorMessage);
    } catch (e) {
      _logger.e('❌ Unexpected error during sign in', error: e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Add a method to initialize the API service with stored token
  Future<void> initializeToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // Add a method to clear the token (for logout)
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> updateNativeLanguage(String nativeLanguage) async {
    _logger.i('🌍 Initiating native language update');
    _logger.d('New language: $nativeLanguage');

    try {
      final token = await _storage.read(key: 'auth_token');
      _logger.d('Making API request to: $_baseUrl/api/auth/update-language');
      
      final response = await _dio.patch(
        '$_baseUrl/api/auth/update-language',
        data: {'nativeLanguage': nativeLanguage},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      _logger.d('API Response Status Code: ${response.statusCode}');
      _logger.d('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ Native language updated successfully');
        return response.data;
      } else {
        _logger.e('❌ Failed to update native language. Status code: ${response.statusCode}');
        throw Exception('Failed to update native language');
      }
    } catch (e) {
      _logger.e('❌ Error updating native language', error: e);
      throw Exception('Error updating native language: $e');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    _logger.i('📧 Initiating password reset request');
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'speakjar://reset-password', // Your deep link URL
      );
      _logger.i('✅ Password reset email sent successfully');
    } catch (e) {
      _logger.e('❌ Error requesting password reset', error: e);
      throw Exception('Error requesting password reset: $e');
    }
  }

  Future<void> resetPasswordWithSupabase({
    required String password,
  }) async {
    _logger.i('🔐 Resetting password with Supabase');
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: password,
        ),
      );
      _logger.i('✅ Password updated successfully');
    } catch (e) {
      _logger.e('❌ Error resetting password', error: e);
      throw Exception('Error resetting password: $e');
    }
  }

  Future<List<Video>> fetchVideos() async {
    _logger.i('📹 Fetching videos');
    
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '$_baseUrl/api/app/videos/fetch-all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> videosJson = response.data['data']['videos'];
        return videosJson.map((json) => Video.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch videos');
      }
    } catch (e) {
      _logger.e('Error fetching videos: $e');
      throw Exception('Error fetching videos: $e');
    }
  }

  Future<Map<String, dynamic>> startScriptChat(String videoId) async {
    _logger.i('🎬 Starting script chat session');
    
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/script-chat/start',
        data: {'videoId': videoId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to start script chat');
      }
    } catch (e) {
      _logger.e('Error starting script chat: $e');
      throw Exception('Error starting script chat: $e');
    }
  }

  Future<Map<String, dynamic>> sendScriptChatMessage(String sessionId, String message) async {
    _logger.i('💬 Sending script chat message');
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/script-chat/message',
        data: {
          'sessionId': sessionId,
          'message': message,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      _logger.e('Error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  Future<void> endScriptChat(String sessionId) async {
    _logger.i('🏁 Ending script chat session');
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/script-chat/end',
        data: {'sessionId': sessionId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to end chat session');
      }
    } catch (e) {
      _logger.e('Error ending chat session: $e');
      throw Exception('Error ending chat session: $e');
    }
  }
}
