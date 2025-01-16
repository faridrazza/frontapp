import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  final stt.SpeechToText _speech = stt.SpeechToText();
  final Logger _logger = Logger();
  bool _isListening = false;
  String _currentText = '';
  String _accumulatedText = '';
  double _confidenceLevel = 0.0;
  Timer? _pauseTimer;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) {
          _logger.i('Speech recognition status: $status');
          if (status == 'notListening' && _isListening) {
            _handlePause();
          }
        },
        onError: (errorNotification) => _logger.e('Speech recognition error: $errorNotification'),
      );
      _logger.i('Speech recognition available: $available');
    } catch (e) {
      _logger.e('Error initializing speech recognition: $e');
    }
  }

  void _handlePause() {
    _pauseTimer?.cancel();
    
    _pauseTimer = Timer(Duration(milliseconds: 500), () {
      if (_isListening) {
        _accumulatedText += ' ' + _currentText;
        _startListening(restart: true);
      }
    });
  }

  Future<void> _startListening({bool restart = false}) async {
    try {
      if (!restart) {
        _accumulatedText = '';
      }
      
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          if (!restart) _currentText = '';
        });

        await _speech.listen(
          onResult: (result) {
            setState(() {
              _currentText = result.recognizedWords;
              _confidenceLevel = result.confidence;
            });
          },
          listenFor: Duration(seconds: 120),
          pauseFor: Duration(seconds: 3),
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.dictation,
        );
        _logger.i(restart ? 'Restarted listening' : 'Started listening');
      }
    } catch (e) {
      _logger.e('Error in speech recognition: $e');
      if (!restart) _showError('Could not start voice recognition');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      
      String finalText = (_accumulatedText + ' ' + _currentText).trim();
      if (finalText.isNotEmpty) {
        widget.onRecordingComplete(finalText);
      }
      
      _currentText = '';
      _accumulatedText = '';
      _confidenceLevel = 0.0;
      _logger.i('Stopped listening. Final text: $finalText');
    } catch (e) {
      _logger.e('Error stopping speech recognition: $e');
      _showError('Could not stop voice recognition');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.isProcessing ? null : _toggleListening,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isListening ? Colors.red : Color(0xFFC6F432),
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? Colors.red : Color(0xFFC6F432))
                      .withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: widget.isProcessing
                ? Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
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

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
