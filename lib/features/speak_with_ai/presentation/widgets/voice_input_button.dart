import 'package:flutter/material.dart';
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import '../../../../core/utils/audio_utils.dart';
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
  Timer? _pauseTimer;
  static const int _pauseThreshold = 2000; // 2 seconds pause threshold

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _currentResponse = '';
    _accumulatedText = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ultraCallback: _handleSpeechUpdate,
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
    );
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
        }
      }
      
      // Handle live text updates during active listening
      if (isListening && liveText.isNotEmpty) {
        _pauseTimer?.cancel();
        
        // If there's accumulated text and new text is different
        if (_accumulatedText.isNotEmpty && liveText != _currentResponse) {
          _currentResponse = liveText;
          // Only append if it's new content
          if (!_accumulatedText.endsWith(_currentResponse)) {
            _accumulatedText = '$_accumulatedText $_currentResponse'.trim();
          }
        } else {
          _currentResponse = liveText;
        }
        
        // Start pause timer
        _pauseTimer = Timer(Duration(milliseconds: _pauseThreshold), () {
          if (_currentResponse.isNotEmpty) {
            setState(() {
              if (_accumulatedText.isEmpty) {
                _accumulatedText = _currentResponse;
              } else if (!_accumulatedText.endsWith(_currentResponse)) {
                _accumulatedText = '$_accumulatedText $_currentResponse'.trim();
              }
              _logger.i('Pause detected, accumulated text: $_accumulatedText');
            });
          }
        });
      }
    });
  }

  void _handleRecordingStop() {
    _pauseTimer?.cancel();
    String finalText = '';
    
    // Combine accumulated and current text
    if (_accumulatedText.isNotEmpty) {
      finalText = _currentResponse.isNotEmpty 
          ? '$_accumulatedText $_currentResponse'.trim()
          : _accumulatedText;
    } else {
      finalText = _currentResponse;
    }
    
    if (finalText.isNotEmpty) {
      _logger.i('Recording completed with text: $finalText');
      widget.onRecordingComplete(finalText.trim());
    }
    
    // Reset state
    _currentResponse = '';
    _accumulatedText = '';
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