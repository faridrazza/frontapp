class RoleplayFeedback {
  final String grammar;
  final String vocabulary;
  final String suggestions;
  final String errorCorrections;
  final String effectiveWords;

  RoleplayFeedback({
    required this.grammar,
    required this.vocabulary,
    required this.suggestions,
    required this.errorCorrections,
    required this.effectiveWords,
  });

  factory RoleplayFeedback.fromJson(Map<String, dynamic> json) {
    return RoleplayFeedback(
      grammar: json['grammar'] ?? '',
      vocabulary: json['vocabulary'] ?? '',
      suggestions: json['suggestions'] ?? '',
      errorCorrections: json['errorCorrections'] ?? '',
      effectiveWords: json['effectiveWords'] ?? '',
    );
  }
}