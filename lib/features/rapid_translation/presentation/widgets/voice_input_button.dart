import 'package:flutter/material.dart';
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import 'package:logger/logger.dart';
import 'dart:async';

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
  String _currentResponse = '';
  String _accumulatedText = '';
  bool _hasSubmitted = false;
  Timer? _pauseTimer;
  static const int _pauseThreshold = 1500; // Reduced to 1.5 seconds for better responsiveness

  @override
  void dispose() {
    _pauseTimer?.cancel();
    super.dispose();
  }

  void _handleSpeechUpdate(String liveText, String finalText, bool isListening) {
    _logger.i('Speech status - Live: $liveText, Final: $finalText, Listening: $isListening');
    
    setState(() {
      // Update listening state
      if (_isListening != isListening) {
        _isListening = isListening;
        
        if (!isListening) {
          _handleRecordingStop();
        } else {
          // Only reset when starting a new recording
          _hasSubmitted = false;
          if (_accumulatedText.isEmpty) {
            _currentResponse = '';
          }
        }
      }
      
      // Handle live text updates during active listening
      if (isListening && liveText.isNotEmpty) {
        _pauseTimer?.cancel();
        
        // If there's accumulated text, append new text
        if (_accumulatedText.isNotEmpty && liveText != _currentResponse) {
          _currentResponse = liveText;
          _accumulatedText = '$_accumulatedText $_currentResponse';
          _logger.i('Accumulated text updated: $_accumulatedText');
        } else {
          _currentResponse = liveText;
        }
        
        // Start pause timer
        _pauseTimer = Timer(Duration(milliseconds: _pauseThreshold), () {
          if (_currentResponse.isNotEmpty) {
            setState(() {
              if (_accumulatedText.isEmpty) {
                _accumulatedText = _currentResponse;
              } else {
                _accumulatedText = '$_accumulatedText $_currentResponse';
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
            ? '$_accumulatedText $_currentResponse'
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
            color: _isListening ? Colors.red : Color(0xFFC6F432),
            boxShadow: [
              BoxShadow(
                color: (_isListening ? Colors.red : Color(0xFFC6F432)).withOpacity(0.3),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                )
              : SpeechToTextUltra(
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
    _logger.e('Voice input error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}