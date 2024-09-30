import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/utils/audio_utils.dart';
import 'package:logger/logger.dart';

class VoiceInputButton extends StatefulWidget {
  final Function(String) onRecordingComplete;

  VoiceInputButton({required this.onRecordingComplete});

  @override
  _VoiceInputButtonState createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _logger.i('VoiceInputButton initialized');
  }

  void _listen() async {
    _logger.i('_listen method called');
    if (!_isListening) {
      _logger.i('Attempting to initialize speech recognition');
      bool available = await _speech.initialize(
        onStatus: (status) {
          _logger.i('Speech recognition status: $status');
          print('Speech recognition status: $status');
        },
        onError: (errorNotification) {
          _logger.e('Speech recognition error: ${errorNotification.errorMsg}');
          print('Speech recognition error: $errorNotification');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${errorNotification.errorMsg}')),
          );
        },
      );
      _logger.i('Speech recognition available: $available');
      if (available) {
        setState(() => _isListening = true);
        _logger.i('Starting to listen');
        _speech.listen(
          onResult: (result) {
            _logger.i('Speech recognition result: ${result.recognizedWords}');
            if (result.finalResult) {
              _logger.i('Final result received: ${result.recognizedWords}');
              widget.onRecordingComplete(result.recognizedWords);
              setState(() => _isListening = false);
            }
          },
        );
      } else {
        _logger.w('Speech recognition not available');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech recognition not available')),
        );
      }
    } else {
      _logger.i('Stopping speech recognition');
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _logger.i('Voice input button tapped');
        _listen();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: _isListening ? Colors.red : Color(0xFFC6F432),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}