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

class SpeakWithAIScreen extends StatelessWidget {
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
                  } else if (state is SpeakWithAIConversation) {
                    return _buildConversationState(context, state);
                  } else if (state is SpeakWithAIEnded) {
                    return Center(child: Text('Roleplay ended. Feedback: ${state.feedback}', style: TextStyle(color: Colors.white)));
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
      // padding: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 8.0),
      child: Row(
        children: [
          Image.asset('assets/images/AI.png', width: 60, height: 60),
          SizedBox(width: 80),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI ASMA', style: TextStyle(color: Color(0xFFC6F432), fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildConversationState(BuildContext context, SpeakWithAIConversation state) {
    return ListView.builder(
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return message.type == MessageType.ai
            ? AiMessageBubble(message: message)
            : UserMessageBubble(message: message);
      },
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