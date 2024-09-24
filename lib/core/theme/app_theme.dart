import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Colors.black;
  static const Color primaryColor = Color(0xFFA3FF52);
  static const Color textColor = Colors.white;

  static ThemeData get theme => ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: textColor),
          labelLarge: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      );
}