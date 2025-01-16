import 'package:flutter/material.dart';
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import 'package:logger/logger.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onRecordingComplete;
  final bool isProcessing;

  const VoiceInputButton({
    Key? key,
    required this.onRecordingComplete,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  _VoiceInputButtonState createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final Logger _logger = Logger();
  bool _isListening = false;
  String _entireResponse = '';
  String _liveResponse = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isListening ? Colors.red : Color(0xFFC6F432),
            boxShadow: [
              BoxShadow(
                color: (_isListening ? Colors.red : Color(0xFFC6F432)).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SpeechToTextUltra(
            ultraCallback: (String liveText, String finalText, bool isListening) {
              setState(() {
                _liveResponse = liveText;
                _entireResponse = finalText;
                _isListening = isListening;
                
                // When speech ends, send the complete response
                if (!isListening && finalText.isNotEmpty) {
                  widget.onRecordingComplete(finalText);
                  _entireResponse = '';
                  _liveResponse = '';
                }
              });
            },
            toStartIcon: Icon(
              Icons.mic_none,
              color: Colors.black,
              size: 30,
            ),
            toPauseIcon: Icon(
              Icons.mic,
              color: Colors.black,
              size: 30,
            ),
          ),
        ),
        if (_isListening)
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              'Tap to stop recording',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
