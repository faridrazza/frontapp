import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';

class TranslationInput extends StatefulWidget {
  final Function(String, int) onSubmit;

  const TranslationInput({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _TranslationInputState createState() => _TranslationInputState();
}

class _TranslationInputState extends State<TranslationInput> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  int _startTime = 0;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => _isListening = false);
          _submitTranslation();
        }
      },
      onError: (errorNotification) => print('Speech recognition error: $errorNotification'),
    );
    if (!available) {
      print('Speech recognition not available');
    }
  }

  void _startListening() async {
    if (!_isListening) {
      if (await _speech.initialize()) {
        setState(() {
          _isListening = true;
          _startTime = DateTime.now().millisecondsSinceEpoch;
        });
        _speech.listen(
          onResult: (result) {
            setState(() => _controller.text = result.recognizedWords);
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _submitTranslation() {
    if (_controller.text.isNotEmpty) {
      final timeTaken = DateTime.now().millisecondsSinceEpoch - _startTime;
      _logger.i('Submitting translation: ${_controller.text}, Time taken: $timeTaken ms');
      widget.onSubmit(_controller.text, timeTaken);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter your translation',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitTranslation,
                ),
              ),
              onTap: () => _startTime = DateTime.now().millisecondsSinceEpoch,
              onSubmitted: (_) => _submitTranslation(),
            ),
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: _isListening ? _stopListening : _startListening,
            color: _isListening ? Colors.red : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.cancel();
    super.dispose();
  }
}
