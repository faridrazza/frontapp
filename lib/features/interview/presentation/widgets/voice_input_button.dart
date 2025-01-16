import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  final stt.SpeechToText _speech = stt.SpeechToText();
  final Logger _logger = Logger();
  bool _isListening = false;
  String _currentText = '';
  double _confidenceLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => _logger.i('Speech recognition status: $status'),
        onError: (errorNotification) => _logger.e('Speech recognition error: $errorNotification'),
      );
      _logger.i('Speech recognition available: $available');
    } catch (e) {
      _logger.e('Error initializing speech recognition: $e');
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      if (!_isListening) {
        bool available = await _speech.initialize();
        if (available) {
          setState(() {
            _isListening = true;
            _currentText = '';
          });
          await _speech.listen(
            onResult: (result) {
              setState(() {
                _currentText = result.recognizedWords;
                _confidenceLevel = result.confidence;
              });
            },
            listenFor: Duration(seconds: 120), // 2 minutes
            pauseFor: Duration(seconds: 10), // 3 seconds pause allowed
            partialResults: true,
            cancelOnError: true,
            listenMode: stt.ListenMode.dictation,
          );
          _logger.i('Started listening');
        }
      }
    } catch (e) {
      _logger.e('Error starting speech recognition: $e');
      _showError('Could not start voice recognition');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      if (_currentText.isNotEmpty) {
        widget.onRecordingComplete(_currentText);
      }
      _currentText = '';
      _confidenceLevel = 0.0;
      _logger.i('Stopped listening');
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
          onTap: widget.isProcessing ? null : _toggleListening, // Changed to tap instead of tap down/up
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

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
