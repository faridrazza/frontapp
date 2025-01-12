class User {
  final String id;
  final String email;
  final String name;
  final String nativeLanguage;
  final bool isProfileComplete;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.nativeLanguage,
    this.isProfileComplete = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      nativeLanguage: json['nativeLanguage'],
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }
} 