abstract class IAuthRepository {
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    required String nativeLanguage,
  });

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> socialSignIn({
    required String provider,
    String? nativeLanguage,
  });
} 