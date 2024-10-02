import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rapid_translation_bloc.dart';
import '../bloc/rapid_translation_event.dart';
import '../bloc/rapid_translation_state.dart';
import 'rapid_translation_game_screen.dart';
import '../widgets/game_setup_form.dart';

class GameSetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rapid Translation Game Setup')),
      body: BlocListener<RapidTranslationBloc, RapidTranslationState>(
        listener: (context, state) {
          if (state is GameStarted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => RapidTranslationGameScreen(),
            ));
          } else if (state is RapidTranslationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: GameSetupForm(
          onSubmit: (level, timer) {
            context.read<RapidTranslationBloc>().add(StartGame(level: level, timer: timer));
          },
        ),
      ),
    );
  }
}
