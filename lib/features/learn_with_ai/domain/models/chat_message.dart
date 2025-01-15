class ChatMessage {
  final String text;
  final bool isUser;
  final bool isSystem;
  final bool isCorrect;
  final bool isError;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isSystem = false,
    this.isCorrect = false,
    this.isError = false,
    this.isLoading = false,
  });

  @override
  String toString() => 'ChatMessage(text: $text, isUser: $isUser, isSystem: $isSystem, isCorrect: $isCorrect, isError: $isError)';
}