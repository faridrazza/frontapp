import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rapid_translation_bloc.dart';
import '../bloc/rapid_translation_event.dart';
import '../bloc/rapid_translation_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/timer_button.dart';
import 'package:logger/logger.dart';

class RapidTranslationGameScreen extends StatelessWidget {
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<RapidTranslationBloc, RapidTranslationState>(
          listener: (context, state) {
            _logger.i('State changed: ${state.runtimeType}');
            if (state is NewSentenceReceived) {
              _logger.i('New sentence received: ${state.translationItem?.englishSentence}');
            }
            if (state is GameEnded) {
              _showGameOverDialog(context, state);
            } else if (state is RapidTranslationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context),
                Divider(color: Colors.grey[300], height: 1),
                Expanded(child: _buildChatSection(context, state)),
                _buildBottomSection(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/AI.png'),
            radius: 20,
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Exit game', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFC6F432),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFC6F432),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Score: ${context.watch<RapidTranslationBloc>().score}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection(BuildContext context, RapidTranslationState state) {
    if (state is RapidTranslationInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<RapidTranslationBloc>().add(StartGame(level: 'Medium', timer: '15'));
      });
      return Center(child: CircularProgressIndicator());
    } else if (state is GameStarted) {
      return Center(child: Text('Game started. Fetching first sentence...'));
    } else if (state is NewSentenceReceived || state is TranslationSubmitted) {
      final translationItem = state is NewSentenceReceived
          ? state.translationItem
          : (state as TranslationSubmitted).translationItem;
      return ListView(
        padding: EdgeInsets.all(16),
        children: [
          ChatBubble(
            message: translationItem?.englishSentence ?? '',
            isUser: false,
          ),
          if (state is TranslationSubmitted)
            ChatBubble(
              message: translationItem?.userTranslation ?? '',
              isUser: true,
            ),
        ],
      );
    } else if (state is RapidTranslationError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircularButton(Icons.text_fields, () {
            // TODO: Implement text input functionality
          }),
          _buildCircularButton(Icons.mic, () {
            // TODO: Implement voice recognition functionality
          }, color: Color(0xFFC6F432)),
          TimerButton(),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed, {Color color = Colors.grey}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(icon, color: Colors.black),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
        backgroundColor: color,
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, GameEnded state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Final Score: ${state.finalScore}\n${state.feedback}'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }
}
