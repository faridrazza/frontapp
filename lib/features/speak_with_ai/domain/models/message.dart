enum MessageType { user, ai }

class Message {
  final String content;
  final bool isAI;
  final String? audioBuffer;

  Message({
    required this.content,
    required this.isAI,
    this.audioBuffer,
  });
}