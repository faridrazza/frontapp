import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/learn_with_ai/domain/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Color(0xFFA25BE3) : Color(0xFF3369FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.text.isNotEmpty ? message.text : 'Error: Empty message',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}