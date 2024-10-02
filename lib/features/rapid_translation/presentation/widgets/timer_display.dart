import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rapid_translation_bloc.dart';
import '../bloc/rapid_translation_event.dart';
import '../bloc/rapid_translation_state.dart';

class TimerDisplay extends StatefulWidget {
  @override
  _TimerDisplayState createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  int _secondsRemaining = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RapidTranslationBloc, RapidTranslationState>(
      listener: (context, state) {
        if (state is GameStarted) {
          _startTimer(int.parse(state.gameSession.timer ?? '0'));
        }
      },
      child: Text(
        'Time: $_secondsRemaining',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _startTimer(int seconds) {
    setState(() => _secondsRemaining = seconds);
    if (seconds > 0) {
      Future.delayed(Duration(seconds: 1), () {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
          _startTimer(_secondsRemaining);
        } else {
          context.read<RapidTranslationBloc>().add(TimeUp());
        }
      });
    }
  }
}
