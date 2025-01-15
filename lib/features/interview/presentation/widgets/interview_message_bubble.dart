import 'package:flutter/material.dart';
import '../../domain/models/interview_message.dart';
import 'package:google_fonts/google_fonts.dart';

class InterviewMessageBubble extends StatelessWidget {
  final InterviewMessage message;
  final Function(InterviewMessage) onPlayMedia;
  final bool isPlaying;

  const InterviewMessageBubble({
    Key? key,
    required this.message,
    required this.onPlayMedia,
    required this.isPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: message.isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isAI) _buildAvatarIcon(),
          SizedBox(width: message.isAI ? 8 : 0),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: message.isAI 
                    ? [Color(0xFFC6F432).withOpacity(0.1), Color(0xFF90E0EF).withOpacity(0.1)]
                    : [Color(0xFF7B61FF).withOpacity(0.1), Color(0xFFFEC4DD).withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: message.isAI ? Color(0xFFC6F432).withOpacity(0.2) : Color(0xFF7B61FF).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (message.isAI ? Color(0xFFC6F432) : Color(0xFF7B61FF)).withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (message.audioBuffer != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: GestureDetector(
                        onTap: () => onPlayMedia(message),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPlaying ? Icons.stop : Icons.play_arrow,
                              color: Color(0xFFC6F432),
                              size: 24,
                            ),
                            if (isPlaying)
                              Container(
                                width: 100,
                                height: 2,
                                margin: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: message.isAI ? 0 : 8),
          if (!message.isAI) _buildUserIcon(),
        ],
      ),
    );
  }

  Widget _buildAvatarIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.smart_toy, color: Colors.black, size: 20),
    );
  }

  Widget _buildUserIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFFFEC4DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.person, color: Colors.black, size: 20),
    );
  }
}
