class ChatMessage {
  final String text;
  final bool isSystem;
  final bool isCorrect;
  final bool isButton;

  ChatMessage({
    required this.text,
    this.isSystem = false,
    this.isCorrect = false,
    this.isButton = false,
  });
}