import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Use this for local development
  static const String _baseUrlDev = 'http://localhost:5000';
  // Use this for production (replace with your actual production URL when ready)
  static const String _baseUrlProd = 'https://your-deployed-backend.com';

  // Set this to true for production, false for local development
  static const bool _isProduction = false;

  static String get _baseUrl => _isProduction ? _baseUrlProd : _baseUrlDev;

  static Future<Map<String, dynamic>> sendOtp(String countryCode, String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send OTP');
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
      final response = await _dio.post(
        '$_baseUrl/api/ai-speak/start-roleplay',
        data: {'scenario': scenario},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

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
      throw Exception('Error starting roleplay: $e');
    }
  }
}