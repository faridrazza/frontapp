import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontapp/core/theme/app_theme.dart';
import 'package:frontapp/features/auth/presentation/screens/phone_entry_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Speaking AI',
      theme: AppTheme.theme,
      home: const PhoneEntryScreen(),
    );
  }
}
