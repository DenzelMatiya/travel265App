// lib/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SupabaseAuthService {
  // Singleton pattern
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  // Sign in with magic link
  // Uses deep link redirect for Android: travel265://login-callback/
  Future<void> signInWithMagicLink(String email) async {
    email = email.trim();
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw Exception('Please enter a valid email address');
    }

    try {
      await supabase.auth.signInWithOtp(
        email: email,
        // Deep link redirect for Android - MUST match AndroidManifest.xml
        redirectTo: 'travel265://login-callback/',
      );
      print('Magic link sent to $email');
    } catch (e) {
      print('Error sending magic link: $e');
      rethrow;
    }
  }

  // Listen for auth state changes (e.g., user signs in/out)
  Stream<AuthState> get authStateStream => supabase.auth.onAuthStateChange;

  // Get the current user ID (useful for database queries)
  String? get currentUserId => supabase.auth.currentUser?.id;

  // Get the current user's email
  String? get currentUserEmail => supabase.auth.currentUser?.email;

  // Check if a user is currently authenticated
  bool get isUserLoggedIn => supabase.auth.currentUser != null;

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}