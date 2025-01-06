import 'package:flutter/material.dart';
import '../../domain/models/interview_message.dart';
import 'package:google_fonts/google_fonts.dart';

class InterviewMessageBubble extends StatelessWidget {
  final InterviewMessage message;
  final VoidCallback? onPlayAudio;

  const InterviewMessageBubble({
    Key? key,
    required this.message,
    this.onPlayAudio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isAI ? Color(0xFFA25BE3) : Color(0xFF3369FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: message.isAI 
                  ? Color(0xFFA25BE3).withOpacity(0.3)
                  : Color(0xFF3369FF).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                message.content,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            if (message.isAI && message.audioBuffer != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onPlayAudio,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
