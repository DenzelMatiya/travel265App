// lib/core/theme/app_theme.dart - PRODUCTION-READY THEME SYSTEM

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🎨 Core Brand Colors
const Color primaryColor = Color(0xFF0B95DA);
const Color secondaryColor = Color(0xFF1A237E);
const Color accentColor = Color(0xFFFFA000);

// 🌓 Extended Color Palette for Dark Mode
const Color _lightSurface = Colors.white;
const Color _darkSurface = Color(0xFF121212);
const Color _darkSurfaceElevated = Color(0xFF1E1E1E);

// 📏 Typography - IMPORTANT: Add 'Inter' font to pubspec.yaml
const String _fontFamily = 'Inter';

class AppTheme {
  AppTheme._();

  /// Main theme factory - Use: `AppTheme.appTheme(darkMode: false)`
  static ThemeData appTheme({bool darkMode = false}) {
    final brightness = darkMode ? Brightness.dark : Brightness.light;
    final base = darkMode ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      useMaterial3: true,

      // 🌈 Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: darkMode ? _darkSurface : _lightSurface,
        surfaceContainer: darkMode ? _darkSurfaceElevated : Colors.white,
      ),

      // 📱 Scaffold Background
      scaffoldBackgroundColor: darkMode ? _darkSurface : _lightSurface,

      // 🎨 AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: darkMode ? Colors.white : Colors.black87,
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
        ),
      ),

      // 🔤 Typography System
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        displaySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: darkMode ? Colors.white70 : Colors.grey[800],
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.4,
          color: darkMode ? Colors.white60 : Colors.grey[700],
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          color: darkMode ? Colors.white54 : Colors.grey[600],
        ),
      ),

      // 🎯 Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withOpacity(0.38),
          disabledForegroundColor: Colors.white.withOpacity(0.38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith<double>(
                (states) {
              if (states.contains(WidgetState.disabled)) return 0;
              if (states.contains(WidgetState.pressed)) return 2;
              return 4;
            },
          ),
        ),
      ),

      // 📝 Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // 🔲 Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // 💬 Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkMode ? Colors.grey[900] : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkMode ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkMode ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: darkMode ? Colors.white70 : Colors.grey[700]),
        hintStyle: TextStyle(color: darkMode ? Colors.white54 : Colors.grey[500]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // 📦 Card Theme
      cardTheme: CardThemeData(
        elevation: darkMode ? 2 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: darkMode ? _darkSurfaceElevated : Colors.white,
        shadowColor: darkMode ? Colors.black54 : Colors.black26,
      ),

      // 🔵 Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // 🏷️ Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        deleteIconColor: primaryColor,
        disabledColor: Colors.grey[400],
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: darkMode ? Colors.white : Colors.black87,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ➗ Divider Theme
      dividerTheme: DividerThemeData(
        color: darkMode ? Colors.grey[800] : Colors.grey[200],
        thickness: 1,
        space: 32,
      ),

      // 🔔 Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkMode ? Colors.grey[800] : Colors.grey[900],
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // 📱 Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkMode ? _darkSurfaceElevated : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // 📅 Date Picker Theme
      datePickerTheme: DatePickerThemeData(
        backgroundColor: darkMode ? _darkSurfaceElevated : Colors.white,
        headerBackgroundColor: primaryColor,
        headerForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Custom theme extension for app-specific semantic colors
  static ThemeExtension<AppColors> get appColors => AppColors(
    success: Colors.green.shade700,
    warning: Colors.orange.shade700,
    error: Colors.red.shade700,
    info: primaryColor,
  );
}

/// 🎨 Custom Theme Extension for semantic colors
/// Usage: `Theme.of(context).extension<AppColors>()?.error`
class AppColors extends ThemeExtension<AppColors> {
  final Color? success;
  final Color? warning;
  final Color? error;
  final Color? info;

  const AppColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  @override
  ThemeExtension<AppColors> copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
      covariant ThemeExtension<AppColors>? other,
      double t,
      ) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
      error: Color.lerp(error, other.error, t),
      info: Color.lerp(info, other.info, t),
    );
  }
}