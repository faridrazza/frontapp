import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rapid_translation_bloc.dart';
import '../bloc/rapid_translation_event.dart';
import '../bloc/rapid_translation_state.dart';
import '../widgets/translation_input.dart';
import '../widgets/timer_display.dart';
import '../widgets/score_display.dart';
import 'package:logger/logger.dart';

class RapidTranslationGameScreen extends StatelessWidget {
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rapid Translation Game')),
      body: BlocConsumer<RapidTranslationBloc, RapidTranslationState>(
        listener: (context, state) {
          _logger.i('State changed: ${state.runtimeType}');
          if (state is NewSentenceReceived) {
            _logger.i('New sentence received in listener: ${state.translationItem?.englishSentence}');
          }
          if (state is GameEnded) {
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
          } else if (state is RapidTranslationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          _logger.i('Building UI for state: ${state.runtimeType}');
          if (state is RapidTranslationInitial) {
            _logger.i('Initial state, triggering StartGame');
            // Trigger StartGame event if it's the initial state
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
            _logger.i('Displaying sentence in builder: ${translationItem?.englishSentence}');
            if (translationItem == null || translationItem.englishSentence == null) {
              _logger.e('TranslationItem or englishSentence is null');
              return Center(child: Text('Error: Unable to load sentence'));
            }
            return Column(
              children: [
                TimerDisplay(),
                ScoreDisplay(),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    translationItem.englishSentence!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // ... rest of the UI ...
              ],
            );
          } else if (state is RapidTranslationError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          _logger.w('Unexpected state: ${state.runtimeType}. Showing loading indicator.');
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
