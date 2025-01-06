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

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({Key? key}) : super(key: key);

  @override
  _InterviewScreenState createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    await _speech.initialize();
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTapDown: (_) async {
              if (!_isListening) {
                bool available = await _speech.initialize();
                if (available) {
                  setState(() => _isListening = true);
                  _speech.listen(
                    onResult: (result) {
                      if (result.finalResult) {
                        context.read<InterviewBloc>().add(
                          SendResponse(result.recognizedWords),
                        );
                        setState(() => _isListening = false);
                      }
                    },
                  );
                }
              }
            },
            onTapUp: (_) {
              if (_isListening) {
                _speech.stop();
                setState(() => _isListening = false);
              }
            },
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
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
