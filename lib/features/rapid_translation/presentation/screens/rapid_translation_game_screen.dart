import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rapid_translation_bloc.dart';
import '../bloc/rapid_translation_event.dart';
import '../bloc/rapid_translation_state.dart';
import '../widgets/translation_input.dart';
import '../widgets/timer_display.dart';
import '../widgets/score_display.dart';

class RapidTranslationGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rapid Translation Game')),
      body: BlocConsumer<RapidTranslationBloc, RapidTranslationState>(
        listener: (context, state) {
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
          if (state is NewSentenceReceived || state is TranslationSubmitted) {
            final translationItem = state is NewSentenceReceived
                ? state.translationItem
                : (state as TranslationSubmitted).translationItem;
            return Column(
              children: [
                TimerDisplay(),
                ScoreDisplay(),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    translationItem.englishSentence,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (state is TranslationSubmitted)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      translationItem.isCorrect!
                          ? 'Correct!'
                          : 'Incorrect. Correct translation: ${translationItem.correctTranslation}',
                      style: TextStyle(
                        color: translationItem.isCorrect! ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                Spacer(),
                TranslationInput(
                  onSubmit: (translation, timeTaken) {
                    context.read<RapidTranslationBloc>().add(
                          SubmitTranslation(translation: translation, timeTaken: timeTaken),
                        );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('End Game'),
                  onPressed: () => context.read<RapidTranslationBloc>().add(EndGame()),
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
