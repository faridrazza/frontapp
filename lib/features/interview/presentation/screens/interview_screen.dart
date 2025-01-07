import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/interview_bloc.dart';
import '../bloc/interview_event.dart';
import '../bloc/interview_state.dart';
import '../widgets/role_selection_form.dart';
import '../widgets/interview_message_bubble.dart';
import '../../../../core/utils/audio_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'interview_feedback_screen.dart';
import 'package:logger/logger.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({Key? key}) : super(key: key);

  @override
  _InterviewScreenState createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isMicAvailable = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSpeech();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          setState(() => _isListening = status == 'listening');
          if (_isListening) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.stop();
            _animationController.reset();
          }
        },
        onError: (error) => _showError('Microphone error: ${error.errorMsg}'),
      );
      setState(() => _isMicAvailable = available);
    } catch (e) {
      _showError('Failed to initialize microphone');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_isMicAvailable) {
      _showError('Microphone not available');
      return;
    }

    try {
      if (await _speech.initialize(
        onStatus: (status) {
          _logger.i('Speech recognition status: $status');
          if (status == 'notListening') {
            if (_isListening) {
              _showError('No speech detected for a while');
              _stopListening();
            }
          }
          setState(() => _isListening = status == 'listening');
          if (_isListening) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.stop();
            _animationController.reset();
          }
        },
        onError: (error) {
          if (error.errorMsg != 'No speech input') {
            _showError('Microphone error: ${error.errorMsg}');
          }
        },
      )) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              if (result.recognizedWords.isNotEmpty) {
                context.read<InterviewBloc>().add(
                  SendResponse(result.recognizedWords),
                );
              }
            }
          },
          listenMode: stt.ListenMode.dictation,
          pauseFor: Duration(seconds: 10),
          partialResults: true,
          cancelOnError: false,
          localeId: 'en_US',
        );
      }
    } catch (e) {
      _logger.e('Error starting microphone: $e');
      _showError('Error starting microphone');
      _stopListening();
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
      setState(() => _isListening = false);
    } catch (e) {
      _logger.e('Error stopping microphone: $e');
      _showError('Error stopping microphone');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopListening();
      AudioUtils.stopAudio();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'AI Interview',
          style: GoogleFonts.inter(
            color: Color(0xFFC8F235),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          BlocBuilder<InterviewBloc, InterviewState>(
            builder: (context, state) {
              if (state is InterviewInProgress) {
                return TextButton(
                  onPressed: () {
                    context.read<InterviewBloc>().add(EndInterview());
                  },
                  child: Text(
                    'End Interview',
                    style: TextStyle(color: Color(0xFFC8F235)),
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<InterviewBloc, InterviewState>(
        listener: (context, state) {
          if (state is InterviewCompleted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => InterviewFeedbackScreen(feedback: state.feedback),
              ),
            );
          } else if (state is InterviewInProgress) {
            if (state.session.messages.isNotEmpty) {
              final latestMessage = state.session.messages.last;
              if (latestMessage.isAI && latestMessage.audioBuffer != null) {
                AudioUtils.playAudio(latestMessage.audioBuffer!);
              }
              Future.delayed(Duration(milliseconds: 100), () {
                _scrollToBottom();
              });
            }
          }
        },
        builder: (context, state) {
          if (state is InterviewInitial) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: RoleSelectionForm(
                  onSubmit: (role, experienceLevel) {
                    context.read<InterviewBloc>().add(
                      StartInterview(
                        role: role,
                        experienceLevel: experienceLevel,
                      ),
                    );
                  },
                ),
              ),
            );
          }

          if (state is InterviewLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8F235)),
              ),
            );
          }

          if (state is InterviewInProgress) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: state.session.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.session.messages[index];
                      return InterviewMessageBubble(
                        message: message,
                        onPlayAudio: message.audioBuffer != null
                            ? () => AudioUtils.playAudio(message.audioBuffer!)
                            : null,
                      );
                    },
                  ),
                ),
                if (state.isProcessing)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8F235)),
                    ),
                  ),
                _buildInputArea(state),
              ],
            );
          }

          if (state is InterviewError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<InterviewBloc>().add(ResetInterview());
                    },
                    child: Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInputArea(InterviewInProgress state) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isListening ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.red : Color(0xFFC8F235),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Color(0xFFC8F235))
                              .withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.black,
                          size: 30,
                        ),
                        if (_isListening)
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _stopListening();
    _scrollController.dispose();
    AudioUtils.stopAudio();
    super.dispose();
  }
}
