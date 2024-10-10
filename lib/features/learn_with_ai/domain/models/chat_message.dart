class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  @override
  String toString() => 'ChatMessage(text: $text, isUser: $isUser)';
}