import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../bloc/script_chat_bloc.dart';
import '../widgets/chat_message_bubble.dart';
import '../../../../core/utils/audio_utils.dart';

class ScriptChatScreen extends StatefulWidget {
  final String videoId;
  final String videoUrl;

  const ScriptChatScreen({
    Key? key,
    required this.videoId,
    required this.videoUrl,
  }) : super(key: key);

  @override
  _ScriptChatScreenState createState() => _ScriptChatScreenState();
}

class _ScriptChatScreenState extends State<ScriptChatScreen> {
  late YoutubePlayerController _videoController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String? _sessionId;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _videoController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              final message = result.recognizedWords;
              _messages.add({
                'isUser': true,
                'message': message,
              });
              context.read<ScriptChatBloc>().add(
                SendMessage(_sessionId!, message),
              );
              setState(() => _isListening = false);
            }
          },
        );
      }
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Script Chat'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // End chat session
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Section (30% of screen height)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: YoutubePlayer(
              controller: _videoController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: const Color(0xFFC6F432),
            ),
          ),
          // Chat Section (70% of screen height)
          Expanded(
            child: BlocConsumer<ScriptChatBloc, ScriptChatState>(
              listener: (context, state) {
                if (state is ChatStarted) {
                  _sessionId = state.sessionId;
                  _messages.add({
                    'isUser': false,
                    'message': state.message,
                  });
                  AudioUtils.playAudio(state.audio);
                } else if (state is MessageSent) {
                  _messages.add({
                    'isUser': false,
                    'message': state.message,
                  });
                  AudioUtils.playAudio(state.audio);
                } else if (state is ChatEnded) {
                  Navigator.pop(context);
                }
              },
              builder: (context, state) {
                return ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return ChatMessageBubble(
                      message: message['message'],
                      isUser: message['isUser'],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? _stopListening : _startListening,
        backgroundColor: _isListening ? Colors.red : const Color(0xFFC6F432),
        child: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }
} 