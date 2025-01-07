import 'package:flutter/material.dart';
import '../../domain/models/interview_message.dart';
import 'package:google_fonts/google_fonts.dart';

class InterviewMessageBubble extends StatelessWidget {
  final InterviewMessage message;
  final VoidCallback? onPlayAudio;
  final bool isPlaying;

  const InterviewMessageBubble({
    Key? key,
    required this.message,
    required this.isPlaying,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                child: ElevatedButton.icon(
                  onPressed: isPlaying ? null : onPlayAudio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 20,
                  ),
                  label: Text(
                    isPlaying ? 'Playing...' : 'Play Audio',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
