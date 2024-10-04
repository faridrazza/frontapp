import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rapid_translation_bloc.dart';
import '../bloc/rapid_translation_state.dart';
import '../bloc/rapid_translation_event.dart';
import 'translation_input.dart';
import '../../domain/models/translation_item.dart';

class ChatInterface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RapidTranslationBloc, RapidTranslationState>(
      builder: (context, state) {
        final messages = (context.read<RapidTranslationBloc>() as RapidTranslationBloc).messages;
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return message.userTranslation == null
                      ? _buildAIMessage(message)
                      : _buildUserMessage(message);
                },
              ),
            ),
            TranslationInput(
              onSubmit: (translation, timeTaken) {
                context.read<RapidTranslationBloc>().add(
                      SubmitTranslation(translation: translation, timeTaken: timeTaken),
                    );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAIMessage(TranslationItem message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.englishSentence),
      ),
    );
  }

  Widget _buildUserMessage(TranslationItem message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isCorrect == true ? Colors.green[300] : Colors.red[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.userTranslation!),
            if (message.isCorrect == false && message.correctTranslation != null)
              Text(
                'Correct: ${message.correctTranslation}',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}