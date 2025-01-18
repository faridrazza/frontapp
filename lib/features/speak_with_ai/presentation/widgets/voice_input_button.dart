import 'package:flutter/material.dart';
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import 'package:logger/logger.dart';
import 'dart:async';

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
  String _accumulatedText = '';
  bool _hasSubmitted = false;
  Timer? _pauseTimer;
  static const int _pauseThreshold = 1800; // 1.8 seconds pause threshold

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _currentResponse = '';
    _accumulatedText = '';
    _hasSubmitted = false;
    super.dispose();
  }

  void _handleSpeechUpdate(String liveText, String finalText, bool isListening) {
    if (!mounted) return;
    
    _logger.i('Speech status - Live: $liveText, Final: $finalText, Listening: $isListening');
    
    setState(() {
      // Update listening state
      if (_isListening != isListening) {
        _isListening = isListening;
        
        if (!isListening) {
          _handleRecordingStop();
        } else {
          // Reset state when starting new recording
          _hasSubmitted = false;
          if (_accumulatedText.isEmpty) {
            _currentResponse = '';
          }
        }
      }
      
      // Handle live text updates during active listening
      if (isListening && liveText.isNotEmpty) {
        _pauseTimer?.cancel();
        
        // Update current response
        _currentResponse = liveText;
        
        // Start pause timer
        _pauseTimer = Timer(Duration(milliseconds: _pauseThreshold), () {
          if (_currentResponse.isNotEmpty && mounted) {
            setState(() {
              if (_accumulatedText.isEmpty) {
                _accumulatedText = _currentResponse;
              } else if (!_accumulatedText.endsWith(_currentResponse)) {
                // Only append if it's not already there
                _accumulatedText = '$_accumulatedText $_currentResponse'.trim();
              }
              _logger.i('Pause detected, accumulated text: $_accumulatedText');
              _currentResponse = '';
            });
          }
        });
      }
    });
  }

  void _handleRecordingStop() {
    _pauseTimer?.cancel();
    if (!_hasSubmitted) {
      _hasSubmitted = true;
      String finalText = '';
      
      // Combine accumulated and current text
      if (_accumulatedText.isNotEmpty) {
        finalText = _currentResponse.isNotEmpty 
            ? '$_accumulatedText $_currentResponse'.trim()
            : _accumulatedText.trim();
      } else {
        finalText = _currentResponse.trim();
      }
      
      if (finalText.isNotEmpty) {
        _logger.i('Recording completed with text: $finalText');
        widget.onRecordingComplete(finalText);
      }
      
      // Reset state
      _currentResponse = '';
      _accumulatedText = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SpeechToTextUltra(
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
    );
  }
}