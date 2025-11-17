// lib/main.dart - PRODUCTION READY

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel265/features/auth/splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your custom theme from material.dart
import 'package:travel265/material.dart'; // 👈 ADDED

void main() async {
  // 🔌 STEP 1: Wake up the Flutter engine
  // This must be called before any async work (like connecting to Supabase).
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 STEP 2: Connect to your Supabase backend
  // ⚠️ CRITICAL: Remove trailing spaces in the URL!
  await Supabase.initialize(
    url: 'https://ksivfkmzkqnamhgvluxx.supabase.co', // ✅ No spaces at the end!
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzaXZma216a3FuYW1oZ3ZsdXh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3Njc5MTgsImV4cCI6MjA3ODM0MzkxOH0.Bx2cQFsnP8wJgJnQO3O3fFHSIHcBF0iWLc1KswNv0PI',
  );

  // 📱 STEP 3: Lock screen orientation to portrait (no landscape)
  // Users won't be able to rotate the device sideways.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 🎨 STEP 4: Style the status bar (top bar with time/battery)
  // - Make background transparent (so app content flows under it)
  // - Icons will be dark (for light mode). We'll handle dark mode later if needed.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Black icons (good for light backgrounds)
    ),
  );

  // 🚀 STEP 5: Launch the app!
  runApp(const Travel265App());
}

// 🧱 The main app widget — the root of your entire UI
class Travel265App extends StatelessWidget {
  const Travel265App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TRAVEL 265",
      // 🛑 Hide the "DEBUG" banner in the top-right corner
      debugShowCheckedModeBanner: false,

      // 🎨 USE YOUR CUSTOM THEME FROM material.dart!
      // This applies all your colors, buttons, text styles, and dark/light mode logic.
      theme: appTheme(darkMode: false),      // 👈 YOUR CUSTOM LIGHT THEME
      darkTheme: appTheme(darkMode: true),   // 👈 YOUR CUSTOM DARK THEME
      themeMode: ThemeMode.system,           // 👈 Follow system setting (light/dark)

      // 🏠 First screen to show: the Splash Screen
      home: const SplashScreen(),

      // 🚫 Disable "glow" effect when scrolling past the edge (Android only)
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: child!,
        );
      },
    );
  }
}