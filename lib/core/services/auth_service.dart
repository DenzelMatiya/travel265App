// lib/core/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

// TODO: Extract to lib/core/utils/logger.dart for app-wide use
final _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, colors: true),
);

/// Centralizes all Supabase authentication operations.
///
/// Implements singleton pattern for single app-wide instance.
/// Handles email, phone, and social auth flows with robust error handling.
///
/// Usage:
/// ```dart
/// final auth = AuthService.instance;
/// await auth.signInWithMagicLink('user@example.com');
/// final user = auth.currentUser;
/// ```
class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  static AuthService get instance => _instance;

  final SupabaseClient _client = Supabase.instance.client;

  // Getters
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sends magic link to [email]
  Future<void> signInWithMagicLink(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: _validateEmail(email),
        emailRedirectTo: _getRedirectUrl(),
      );
      _logger.i('✅ Magic link sent to ${email.trim()}');
    } catch (e) {
      _logger.e('❌ Magic link failed', error: e);
      rethrow;
    }
  }

  /// Email/password sign-in
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: _validateEmail(email),
        password: password,
      );
      _logger.i('✅ User signed in: ${response.user?.email}');
      return response;
    } catch (e) {
      _logger.e('❌ Sign-in failed', error: e);
      rethrow;
    }
  }

  /// Signs up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: _validateEmail(email),
        password: password,
        data: metadata ?? {},
      );
      _logger.i('✅ Sign-up initiated: ${response.user?.email}');
      return response;
    } catch (e) {
      _logger.e('❌ Sign-up failed', error: e);
      rethrow;
    }
  }

  /// Sends password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        _validateEmail(email),
        redirectTo: _getRedirectUrl(),
      );
      _logger.i('✅ Reset email sent to $email');
    } catch (e) {
      _logger.e('❌ Password reset failed', error: e);
      rethrow;
    }
  }

  /// Updates user password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _logger.i('✅ Password updated');
      return response;
    } catch (e) {
      _logger.e('❌ Password update failed', error: e);
      rethrow;
    }
  }

  /// Signs out current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _logger.i('✅ User signed out');
    } catch (e) {
      _logger.e('❌ Sign-out failed', error: e);
      rethrow;
    }
  }

  /// Validates email format
  String _validateEmail(String email) {
    final trimmed = email.trim().toLowerCase();
    if (trimmed.isEmpty) throw ArgumentError('Email cannot be empty');

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(trimmed)) {
      throw FormatException('Invalid email format: $trimmed');
    }
    return trimmed;
  }

  /// Gets redirect URL for auth callbacks
  String _getRedirectUrl() {
    // TODO: Configure in .env or constants file
    // Mobile: 'io.supabase.travel265://login-callback/'
    // Web: window.location.origin
    return 'io.supabase.travel265://login-callback/';
  }
}