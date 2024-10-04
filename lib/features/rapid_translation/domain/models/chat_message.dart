class ChatMessage {
  final String text;
  final bool isSystem;
  final bool isCorrect;
  final bool isButton;
  final bool isLoading;
  final bool isError;

  ChatMessage({
    required this.text,
    this.isSystem = false,
    this.isCorrect = false,
    this.isButton = false,
    this.isLoading = false,
    this.isError = false,
  });
}