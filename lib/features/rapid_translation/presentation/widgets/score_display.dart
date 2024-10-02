import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rapid_translation_bloc.dart';
import '../bloc/rapid_translation_state.dart';

class ScoreDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RapidTranslationBloc, RapidTranslationState>(
      builder: (context, state) {
        final score = (context.read<RapidTranslationBloc>() as RapidTranslationBloc).score;
        return Text(
          'Score: $score',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
