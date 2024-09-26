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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI ASMA', style: TextStyle(color: Colors.white)),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFFC6F432),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Online', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: BlocBuilder<SpeakWithAIBloc, SpeakWithAIState>(
        builder: (context, state) {
          if (state is SpeakWithAIInitial) {
            return RolePlayOptions(
              onSelectRolePlay: (scenario) {
                context.read<SpeakWithAIBloc>().add(StartRoleplay(scenario));
              },
            );
          } else if (state is SpeakWithAIConversation) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return message.type == MessageType.ai
                          ? AiMessageBubble(message: message)
                          : UserMessageBubble(message: message);
                    },
                  ),
                ),
                VoiceInputButton(
                  onRecordingComplete: (message) {
                    context.read<SpeakWithAIBloc>().add(SendMessage(message));
                  },
                ),
              ],
            );
          } else if (state is SpeakWithAIEnded) {
            return Center(child: Text('Roleplay ended. Feedback: ${state.feedback}'));
          } else if (state is SpeakWithAIError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}