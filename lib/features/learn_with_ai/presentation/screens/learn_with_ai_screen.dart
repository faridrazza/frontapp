import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontapp/core/services/api_service.dart';
import 'package:frontapp/features/learn_with_ai/presentation/bloc/learn_with_ai_bloc.dart';
import 'package:frontapp/features/learn_with_ai/presentation/widgets/chat_bubble.dart';
import 'package:frontapp/features/learn_with_ai/domain/models/chat_message.dart';
import 'package:logger/logger.dart';
import 'dart:async';

class LearnWithAiScreen extends StatefulWidget {
  const LearnWithAiScreen({Key? key}) : super(key: key);

  @override
  _LearnWithAiScreenState createState() => _LearnWithAiScreenState();
}

class _LearnWithAiScreenState extends State<LearnWithAiScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  String _currentRecording = '';
  final Logger _logger = Logger();
  late AnimationController _micAnimationController;
  Timer? _recordingTimer;
  static const int _recordingTimeout = 30; // 30 seconds max recording time

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognition();
    _micAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _initializeSpeechRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech recognition status: $status'),
      onError: (errorNotification) => print('Speech recognition error: $errorNotification'),
    );
    if (!available) {
      print('Speech recognition not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Divider(color: Color(0xFF333333), height: 1),
            Expanded(
              child: _buildChatArea(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/AI.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Hiba AI',
            style: GoogleFonts.inter(
              color: Color(0xFFC6F432),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return BlocConsumer<LearnWithAiBloc, LearnWithAiState>(
      listener: (context, state) {
        if (state is LearnWithAiLoaded) {
          _scrollToBottom();
        }
      },
      builder: (context, state) {
        if (state is LearnWithAiLoaded) {
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              return ChatBubble(message: message);
            },
          );
        } else if (state is LearnWithAiError) {
          return Center(child: Text('Error: ${state.error}', style: TextStyle(color: Colors.red)));
        }
        return Container();
      },
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _isListening ? 'Listening...' : 'Type your message',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: Color(0xFFC6F432)),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _micAnimationController,
              builder: (context, child) {
                return Container(
                  width: 50 + (_isListening ? _micAnimationController.value * 10 : 0),
                  height: 50 + (_isListening ? _micAnimationController.value * 10 : 0),
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
                  child: Icon(
                    Icons.mic,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
        ],
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

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onError: (error) => _handleSpeechError(error.errorMsg),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _currentRecording = '';
        });
        _micAnimationController.repeat(reverse: true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _currentRecording = result.recognizedWords;
              _textController.text = _currentRecording;
            });
          },
        );
        _startRecordingTimer();
      } else {
        _handleSpeechError("Speech recognition not available");
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    _micAnimationController.stop();
    _micAnimationController.reset();
    setState(() => _isListening = false);
    _cancelRecordingTimer();
    if (_currentRecording.isNotEmpty) {
      _sendMessage(_currentRecording);
      _currentRecording = '';
      _textController.clear();
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer(Duration(seconds: _recordingTimeout), () {
      _stopListening();
    });
  }

  void _cancelRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _handleSpeechError(String errorMsg) {
    _logger.e('Speech recognition error: $errorMsg');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $errorMsg')),
    );
    _stopListening();
  }

  void _sendMessage(String text) {
    if (text.isNotEmpty) {
      _logger.i('Sending message from UI: $text');
      context.read<LearnWithAiBloc>().add(SendMessage(text));
      _textController.clear();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _micAnimationController.dispose();
    _cancelRecordingTimer();
    super.dispose();
  }
}