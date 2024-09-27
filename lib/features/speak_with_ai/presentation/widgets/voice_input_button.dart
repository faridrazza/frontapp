import 'package:flutter/material.dart';
import '../../../../core/utils/audio_utils.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputButton extends StatelessWidget {
  final Function(String) onRecordingComplete;

  VoiceInputButton({required this.onRecordingComplete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement voice recording functionality
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Color(0xFFC6F432),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.mic, color: Colors.black, size: 30),
      ),
    );
  }
}