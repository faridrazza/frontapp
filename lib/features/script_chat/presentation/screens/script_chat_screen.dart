import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../bloc/script_chat_bloc.dart';
import '../widgets/chat_message_bubble.dart';
import '../../../../core/utils/audio_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/features/auth/presentation/screens/home_screen.dart';


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

class _ScriptChatScreenState extends State<ScriptChatScreen> with WidgetsBindingObserver {
  late YoutubePlayerController _videoController;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String? _sessionId;
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeSpeech();
    WidgetsBinding.instance.addObserver(this);
  }

  void _initializeVideo() {
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    _videoController = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoController.dispose();
    AudioUtils.stopAudio(); // Stop any playing audio
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      AudioUtils.stopAudio(); // Stop audio when app goes to background
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Section
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              padding: const EdgeInsets.only(top: 8),
              child: YoutubePlayer(
                controller: _videoController,
                showVideoProgressIndicator: true,
                progressIndicatorColor: const Color(0xFFC6F432),
              ),
            ),
            // Chat Section
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
                    _scrollToBottom();
                  } else if (state is MessageSent) {
                    _messages.add({
                      'isUser': false,
                      'message': state.message,
                    });
                    AudioUtils.playAudio(state.audio);
                    _scrollToBottom();
                  } else if (state is ChatEnded) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(isNewUser: false),
                      ),
                      (route) => false,
                    );
                  }
                },
                builder: (context, state) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Container(
                          alignment: message['isUser'] 
                              ? Alignment.centerRight 
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: message['isUser']
                                    ? [const Color(0xFF7B61FF).withOpacity(0.1), const Color(0xFFFEC4DD).withOpacity(0.1)]
                                    : [const Color(0xFFC6F432).withOpacity(0.1), const Color(0xFF90E0EF).withOpacity(0.1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: message['isUser']
                                    ? const Color(0xFF7B61FF).withOpacity(0.2)
                                    : const Color(0xFFC6F432).withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (message['isUser'] ? const Color(0xFF7B61FF) : const Color(0xFFC6F432)).withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              message['message'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Bottom Controls Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // End Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_sessionId != null) {
                          context.read<ScriptChatBloc>().add(EndChat(_sessionId!));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'End',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Mic Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: _isListening ? _stopListening : _startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFC6F432), Color(0xFF90E0EF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.smart_toy, color: Colors.black, size: 20),
    );
  }

  Widget _buildUserIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFFFEC4DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.person, color: Colors.black, size: 20),
    );
  }
} 