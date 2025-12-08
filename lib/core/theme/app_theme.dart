// lib/core/theme/app_theme.dart - SYSTEM FONT VERSION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🎨 Core Brand Colors (keep these)
const primaryColor = Color(0xFF0B95DA);
const secondaryColor = Color(0xFF1A237E);
const accentColor = Color(0xFFFFA000);

class AppTheme {
  AppTheme._();

  static ThemeData appTheme({bool darkMode = false}) {
    final brightness = darkMode ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
      ),

      // ... all your other theme properties ...

      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        // Just REMOVE fontFamily from ALL TextStyles
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: darkMode ? Colors.white70 : Colors.grey[800],
        ),
      ),

      // No .apply() needed
    );
  }
}