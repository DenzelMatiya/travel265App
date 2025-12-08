// lib/main.dart - PRODUCTION READY

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'core/theme/app_theme.dart';
import 'core/blocs/auth/auth_bloc.dart';
import 'core/blocs/auth/auth_event.dart';
import 'core/widgets/auth_wrapper.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
  ),
);

void main() async {
  runZonedGuarded<Future<void>>(
        () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Lock portrait orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // Initialize Supabase
      try {
        await Supabase.initialize(
          url: 'https://ksivfkmzkqnamhgvluxx.supabase.co',
          anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtzaXZma216a3FuYW1oZ3ZsdXh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3Njc5MTgsImV4cCI6MjA3ODM0MzkxOH0.Bx2cQFsnP8wJgJnQO3O3fFHSIHcBF0iWLc1KswNv0PI',
        );
        logger.i("✅ Supabase initialized successfully");
      } catch (e, stackTrace) {
        logger.e("❌ Supabase init failed", error: e, stackTrace: stackTrace);
        runApp(const SupabaseErrorApp());
        return;
      }

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      );

      runApp(const Travel265App());
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
    return BlocProvider(
      // Create AuthBloc and immediately check auth status
      create: (context) => AuthBloc()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: "TRAVEL 265",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.appTheme(darkMode: false),
        darkTheme: AppTheme.appTheme(darkMode: true),
        themeMode: ThemeMode.system,
        // AuthWrapper handles all routing based on auth state
        home: const AuthWrapper(),
        builder: (context, child) {
          return MediaQuery.withNoTextScaling(
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                overscroll: false,
                physics: const ClampingScrollPhysics(),
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

/// Error screen shown when Supabase initialization fails
class SupabaseErrorApp extends StatelessWidget {
  const SupabaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off,
                    size: 50,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Connection Error",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Unable to connect to the server.\nPlease check your internet connection and try again.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Restart the app
                    // Note: This is a simplified approach
                    // In production, consider using restart_app package
                    SystemNavigator.pop();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}