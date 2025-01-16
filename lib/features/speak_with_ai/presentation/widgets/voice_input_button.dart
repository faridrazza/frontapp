import 'package:flutter/material.dart';
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import '../../../../core/utils/audio_utils.dart';
import 'package:logger/logger.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onRecordingComplete;

  const VoiceInputButton({
    Key? key,
    required this.onRecordingComplete,
  }) : super(key: key);

  @override
  _VoiceInputButtonState createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final Logger _logger = Logger();
  bool _isListening = false;
  String _currentResponse = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
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
            _logger.i('Speech status - Live: $liveText, Final: $finalText, Listening: $isListening');
            
            setState(() {
              // Update listening state
              if (_isListening != isListening) {
                _isListening = isListening;
                
                // If stopping listening and we have text, send it
                if (!isListening && _currentResponse.isNotEmpty) {
                  _logger.i('Recording completed with text: $_currentResponse');
                  widget.onRecordingComplete(_currentResponse);
                  _currentResponse = ''; // Reset for next recording
                }
              }
              
              // Update current response with live text
              if (isListening && liveText.isNotEmpty) {
                _currentResponse = liveText;
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
    );
  }

  void _showError(String message) {
    _logger.e('Voice input error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}