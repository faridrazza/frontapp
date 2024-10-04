import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontapp/core/theme/app_theme.dart';
import 'package:frontapp/features/auth/presentation/screens/phone_entry_screen.dart';
import 'package:frontapp/features/rapid_translation/presentation/bloc/rapid_translation_bloc.dart';
import 'package:frontapp/features/rapid_translation/domain/repositories/rapid_translation_repository.dart';
import 'package:frontapp/core/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RapidTranslationBloc>(
          create: (context) => RapidTranslationBloc(
            RapidTranslationRepository(ApiService()),
          ),
        ),
        // Add other BlocProviders here if needed
      ],
      child: MaterialApp(
        title: 'English Speaking AI',
        theme: AppTheme.theme,
        home: const PhoneEntryScreen(),
      ),
    );
  }
}
