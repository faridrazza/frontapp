import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/speak_with_ai_bloc.dart';
import '../bloc/speak_with_ai_state.dart';
import '../bloc/speak_with_ai_event.dart';
import '../widgets/ai_message_bubble.dart';
import '../widgets/user_message_bubble.dart';
import '../widgets/role_play_options.dart';
import '../widgets/voice_input_button.dart';
import '../../domain/models/message.dart';
import '../../../../core/utils/audio_utils.dart';
import '../widgets/scrollable_chat_view.dart';
import 'package:logger/logger.dart';

class SpeakWithAIScreen extends StatefulWidget {
  @override
  _SpeakWithAIScreenState createState() => _SpeakWithAIScreenState();
}

class _SpeakWithAIScreenState extends State<SpeakWithAIScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10), // Increased duration for slower rotation
    )..repeat(); // This will make it rotate continuously in one direction
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _logger.i('SpeakWithAIScreen initialized');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Divider(color: Colors.grey[800], height: 1),
            Expanded(
              child: BlocBuilder<SpeakWithAIBloc, SpeakWithAIState>(
                builder: (context, state) {
                  if (state is SpeakWithAIInitial) {
                    return _buildInitialState(context);
                  } else if (state is SpeakWithAIConversation || state is SpeakWithAIEnded) {
                    return _buildConversationState(context, state);
                  } else if (state is SpeakWithAIError) {
                    return Center(child: Text('Error: ${state.message}', style: TextStyle(color: Colors.white)));
                  } else {
                    return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC6F432))));
                  }
                },
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 8.0),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * 3.14159, // Full rotation
                child: child,
              );
            },
            child: Image.asset('assets/images/AI.png', width: 60, height: 60),
          ),
          SizedBox(width: 80),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI FARID', style: TextStyle(color: Color(0xFFC6F432), fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFFC6F432),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('Online', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            // padding: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                  
                Image.asset('assets/images/aichat.png', width: 40, height: 40),
              
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFA25BE3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Hi, I'm Farid, your English speaking partner",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          RolePlayOptions(
            onSelectRolePlay: (scenario) {
              context.read<SpeakWithAIBloc>().add(StartRoleplay(scenario));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversationState(BuildContext context, SpeakWithAIState state) {
    if (state is SpeakWithAIConversation) {
      return ScrollableChatView(
        messages: state.messages,
        isLoading: state.isLoading,
      );
    } else if (state is SpeakWithAIEnded) {
      return _buildFeedbackView(state.feedback);
    } else {
      return Center(child: Text('Unexpected state', style: TextStyle(color: Colors.white)));
    }
  }

  Widget _buildFeedbackView(Map<String, dynamic> feedback) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Roleplay Feedback', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _buildFeedbackSection('Grammar', feedback['grammar']),
          _buildFeedbackSection('Pronunciation', feedback['pronunciation']),
          _buildFeedbackSection('Vocabulary', feedback['vocabulary']),
          _buildFeedbackSection('Suggestions', feedback['suggestions']),
          _buildFeedbackSection('Error Corrections', feedback['errorCorrections']),
          _buildFeedbackSection('Effective Words', feedback['effectiveWords']),
          _buildFeedbackSection('Overall Feedback', feedback['overallFeedback']),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Color(0xFFC6F432), fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(content, style: TextStyle(color: Colors.white, fontSize: 16)),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTextInputButton(),
          VoiceInputButton(
            onRecordingComplete: (message) {
              _logger.i('Recording completed. Message: $message');
              print("Recording completed. Sending message: $message");
              context.read<SpeakWithAIBloc>().add(SendMessage(message));
            },
          ),
          _buildCancelButton(context),
        ],
      ),
    );
  }

  Widget _buildTextInputButton() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.purple.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(Icons.chat_bubble_outline, color: Colors.white),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}