class GameSession {
  final String id;
  final String level;
  final String? timer;

  GameSession({required this.id, required this.level, this.timer});

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['gameSessionId'],
      level: json['gameLevel'],
      timer: json['timer'],
    );
  }
}
