class TranslationItem {
  final String englishSentence;
  final String? userTranslation;
  final String? correctTranslation;
  final bool? isCorrect;

  TranslationItem({
    required this.englishSentence,
    this.userTranslation,
    this.correctTranslation,
    this.isCorrect,
  });
}
