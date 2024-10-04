import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rapid_translation_bloc.dart';
import '../screens/game_setup_screen.dart';
import '../../domain/repositories/rapid_translation_repository.dart';
import '../../../../core/services/api_service.dart';

class RapidTranslationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<RapidTranslationBloc>(
      create: (context) => RapidTranslationBloc(
        RapidTranslationRepository(ApiService()),
      ),
      child: GameSetupScreen(),
    );
  }
}