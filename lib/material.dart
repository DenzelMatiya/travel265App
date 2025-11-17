// lib/material.dart
//this file will make sure the theme stays consistent across the whole app

import 'package:flutter/material.dart';

//main app colors
const Color primaryColor = Color(0xFF0b95da);
const Color secondaryColor = Color(0xFF1a237e);
const Color accentColor = Color(0xFFFFA000);

//main theme, allows switching between light and dark mode plus defines text and button styles
ThemeData appTheme({bool darkMode = false}) {
  final base = darkMode ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: darkMode ? Brightness.dark : Brightness.light,
    ),
    scaffoldBackgroundColor: darkMode ? Colors.grey[900] : Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent, // Required for true transparency in M3
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
      displayMedium: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      displaySmall: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
      bodyMedium: const TextStyle(fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
  );
}