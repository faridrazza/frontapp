import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/rapid_translation/domain/models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onNextSentence;

  const ChatBubble({Key? key, required this.message, this.onNextSentence}) : super(key: key);

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
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (message.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Loading...',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
          ),
        ],
      );
    } else if (message.isButton) {
      return ElevatedButton(
        onPressed: onNextSentence,
        child: Text('Get the next sentence'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      );
    } else {
      return Text(
        message.text,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      );
    }
  }

  Color _getBubbleColor() {
    if (message.isSystem) {
      return Color(0xFFA25BE3);
    } else if (message.isCorrect) {
      return Colors.green;
    } else if (message.isError) {
      return Colors.red;
    } else if (!message.isCorrect && !message.isSystem) {
      return Colors.red;
    } else {
      return Color(0xFF3369FF);
    }
  }
}