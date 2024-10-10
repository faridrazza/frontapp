import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/learn_with_ai/domain/models/chat_message.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isUser ? Color(0xFFA25BE3) : Color(0xFF3369FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              message.text.isNotEmpty ? message.text : 'Error: Empty message',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          if (!message.isUser)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: TextToSpeechButton(text: message.text),
            ),
        ],
      ),
    );
  }
}

class TextToSpeechButton extends StatefulWidget {
  final String text;

  const TextToSpeechButton({Key? key, required this.text}) : super(key: key);

  @override
  _TextToSpeechButtonState createState() => _TextToSpeechButtonState();
}

class _TextToSpeechButtonState extends State<TextToSpeechButton> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(0.8); // Even lower pitch for a more masculine voice

    var voices = await _flutterTts.getVoices;
    print("Available voices: $voices"); // For debugging

    // Try to find a male voice
    var maleVoice = voices.firstWhere(
      (voice) => voice['name'].toString().toLowerCase().contains('male') ||
                  voice['name'].toString().toLowerCase().contains('guy') ||
                  voice['name'].toString().toLowerCase().contains('man'),
      orElse: () => null,
    );

    if (maleVoice != null) {
      print("Setting male voice: ${maleVoice['name']}"); // For debugging
      await _flutterTts.setVoice({
        "name": maleVoice['name'],
        "locale": maleVoice['locale'],
      });
    } else {
      print("No specific male voice found, trying alternatives"); // For debugging
      // If no male voice found, try these alternatives
      await _flutterTts.setVoice({"name": "en-us-x-sfg#male_1-local"});
      // If the above doesn't work, you can try:
      // await _flutterTts.setVoice({"name": "en-US-Wavenet-D"});
    }

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _speak() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      setState(() {
        _isSpeaking = true;
      });
      await _flutterTts.speak(widget.text);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _speak,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xFF3369FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isSpeaking ? Icons.stop : Icons.volume_up,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 4),
            Text(
              _isSpeaking ? 'Stop' : 'Listen',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}