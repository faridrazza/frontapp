import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Logger _logger = Logger();

  // Use this for local development
  static const String _baseUrlDev = 'http://192.168.0.104:5000'; // Replace with your computer's IP
  // Use this for production (replace with your actual production URL when ready)
  static const String _baseUrlProd = 'https://your-deployed-backend.com';

  // Set this to true for production, false for local development
  static const bool _isProduction = false;

  static String get _baseUrl => _isProduction ? _baseUrlProd : _baseUrlDev;

  Future<Map<String, dynamic>> sendOtp(String countryCode, String phoneNumber) async {
    _logger.i('Sending OTP');
    _logger.d('Country code: $countryCode');
    _logger.d('Phone number: $phoneNumber');
    _logger.d('Base URL: $_baseUrl');

    // Ensure country code starts with '+'
    if (!countryCode.startsWith('+')) {
      countryCode = '+$countryCode';
    }

    // Remove any non-digit characters from the phone number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    _logger.d('Formatted country code: $countryCode');
    _logger.d('Formatted phone number: $phoneNumber');

    try {
      _logger.d('Preparing API request');
      final response = await _dio.post(
        '$_baseUrl/api/auth/send-otp',
        data: {
          'countryCode': countryCode,
          'phoneNumber': phoneNumber,
        },
      );

      _logger.d('API response received');
      _logger.d('Status code: ${response.statusCode}');
      _logger.d('Response data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('OTP sent successfully');
        return response.data;
      } else {
        _logger.w('Failed to send OTP');
        _logger.w('Status code: ${response.statusCode}');
        _logger.w('Response data: ${response.data}');
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      _logger.e('Error sending OTP', error: e);
      if (e is DioException) {
        _logger.d('DioException details:');
        _logger.d('Type: ${e.type}');
        _logger.d('Message: ${e.message}');
        _logger.d('Response: ${e.response}');
        if (e.response != null) {
          _logger.d('Response status code: ${e.response?.statusCode}');
          _logger.d('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Error sending OTP: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String countryCode, String phoneNumber, String otp) async {
    try {
      final response = await _dio.post('$_baseUrl/api/auth/verify-otp', data: {
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storage.write(key: 'auth_token', value: token);
        return response.data;
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  Future<Map<String, dynamic>> completeProfile(String name, String email, String nativeLanguage) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '$_baseUrl/api/auth/complete-profile',
        data: {
          'name': name,
          'email': email,
          'nativeLanguage': nativeLanguage,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to complete profile');
      }
    } catch (e) {
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
        return {
          'conversationId': response.data['conversationId'],
          'initialPrompt': response.data['initialPrompt'],
          'audioBuffer': response.data['audioBuffer'],
          'wsUrl': response.data['wsUrl'],
        };
      } else {
        throw Exception('Failed to start roleplay');
      }
    } catch (e) {
      print('Error details: $e');
      throw Exception('Error starting roleplay: $e');
    }
  }
}