import 'package:flutter/material.dart';
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import 'package:logger/logger.dart';
import 'dart:async';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onRecordingComplete;
  final bool isProcessing;

  const VoiceInputButton({
    required this.onRecordingComplete,
    this.isProcessing = false,
    Key? key,
  }) : super(key: key);

  @override
  _VoiceInputButtonState createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final Logger _logger = Logger();
  bool _isListening = false;
  String _currentResponse = '';
  String _accumulatedText = '';

  void _handleSpeechUpdate(String liveText, String finalText, bool isListening) {
    if (!mounted) return;
    
    _logger.i('Speech status - Live: $liveText, Final: $finalText, Listening: $isListening');
    
    setState(() {
      // Update listening state
      if (_isListening != isListening) {
        _isListening = isListening;
        
        if (!isListening) {
          _handleRecordingStop(finalText);
        } else {
          // Reset state when starting new recording
          _currentResponse = '';
          _accumulatedText = '';
        }
      }
      
      // Handle live text updates during active listening
      if (isListening && liveText.isNotEmpty) {
        _currentResponse = liveText;
      }
    });
  }

  void _handleRecordingStop(String finalText) {
    if (finalText.isEmpty) return;
    
    _logger.i('Recording completed with text: $finalText');
    widget.onRecordingComplete(finalText);
    
    setState(() {
      _currentResponse = '';
      _accumulatedText = '';
      _isListening = false;
    });
  }

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
            color: _isListening ? Colors.red.withOpacity(0.3) : Color(0xFFC6F432).withOpacity(0.3),
            boxShadow: [
              BoxShadow(
                color: _isListening ? Colors.red.withOpacity(0.2) : Color(0xFFC6F432).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: widget.isProcessing
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : SpeechToTextUltra(
                  ultraCallback: _handleSpeechUpdate,
                  toStartIcon: Icon(
                    Icons.mic_none,
                    color: Colors.white,
                    size: 30,
                  ),
                  toPauseIcon: Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
        ),
        if (_isListening && !widget.isProcessing)
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
}
