import 'package:flutter/material.dart';
import '../../domain/models/message.dart';
import '../../../../core/utils/audio_utils.dart';

class AiMessageBubble extends StatelessWidget {
  final Message message;

  const AiMessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.purple,
            child: Icon(Icons.android, color: Colors.white),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(color: Colors.white),
                  ),
                  if (message.audioBuffer != null)
                    IconButton(
                      icon: Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: () => AudioUtils.playAudio(message.audioBuffer!),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}