import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/rapid_translation/domain/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isSystem ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getBubbleColor(),
          borderRadius: BorderRadius.circular(20),
        ),
        child: message.isButton
            ? ElevatedButton(
                onPressed: () {
                  // Handle next sentence button press
                },
                child: Text('Get the next sentence'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              )
            : Text(
                message.text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Color _getBubbleColor() {
    if (message.isSystem) {
      return Color(0xFFA25BE3);
    } else if (message.isCorrect) {
      return Colors.green;
    } else if (!message.isCorrect) {
      return Colors.red;
    } else {
      return Color(0xFF3369FF);
    }
  }
}