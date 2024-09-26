import 'message.dart';

class Conversation {
  final String id;
  final List<Message> messages;

  Conversation({required this.id, required this.messages});
}