// lib/main.dart - REFINED VERSION

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel265/core/theme/app_theme.dart'; // ✅ FIXED: More conventional import path
import 'package:travel265/features/auth/splashscreen.dart';
import 'package:travel265/core/services/services.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    // printEmojis: true, // Removed: deprecated in logger ^2.0.0
  ),
);

void main() async {
  runZonedGuarded<Future<void>>(
        () async {
      WidgetsFlutterBinding.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      try {
        await Supabase.initialize(
          url: 'https://ksivfkmzkqnamhgvluxx.supabase.co', // ✅ FIXED: Removed trailing space
          anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzaXZma216a3FuYW1oZ3ZsdXh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3Njc5MTgsImV4cCI6MjA3ODM0MzkxOH0.Bx2cQFsnP8wJgJnQO3O3fFHSIHcBF0iWLc1KswNv0PI',
        );
        logger.i("✅ Supabase initialized successfully");
      } catch (e, stackTrace) {
        logger.e("❌ Supabase init failed", error: e, stackTrace: stackTrace);
        runApp(const SupabaseErrorApp());
        return;
      }

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      runApp(
        MultiBlocProvider(
          providers: [
            // TODO: Add your global Blocs here (e.g., AuthBloc, BookingBloc)
          ],
          child: const Travel265App(),
        ),
      );
    },
        (error, stackTrace) {
      logger.e("🔥 UNCAUGHT ERROR", error: error, stackTrace: stackTrace);
    },
  );
}

class Travel265App extends StatelessWidget {
  const Travel265App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TRAVEL 265",
      debugShowCheckedModeBanner: false,

      theme: AppTheme.appTheme(darkMode: false),
      darkTheme: AppTheme.appTheme(darkMode: true),
      themeMode: ThemeMode.system,

      home: const SplashScreen(),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(
              overscroll: false,
              physics: const ClampingScrollPhysics(),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}

class SupabaseErrorApp extends StatelessWidget {
  const SupabaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Connection Error",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                "Please check your internet connection\nand try again.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}