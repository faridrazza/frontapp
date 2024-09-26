enum MessageType { user, ai }

class Message {
  final String content;
  final MessageType type;
  final String? audioBuffer;

  Message({required this.content, required this.type, this.audioBuffer});
}