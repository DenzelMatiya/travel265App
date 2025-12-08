// lib/core/services/auth_service.dart - PRODUCTION-READY
// Add this method to AuthService class

/// 📧 Magic Link with Role Context
Future<void> signInWithMagicLink(String email, {UserRole? intendedRole}) async {
  try {
    final validatedEmail = _validateEmail(email);

    // Include role in redirect URL for post-login handling
    final redirectUrl = '${_getRedirectUrl()}?role=${intendedRole?.name ?? 'guest'}';

    await _client.auth.signInWithOtp(
      email: validatedEmail,
      emailRedirectTo: redirectUrl,
    );

    _logger.i('✅ Magic link sent to $validatedEmail (role: ${intendedRole?.name})');
  } catch (e, stackTrace) {
    _logger.e('❌ Magic link failed', error: e, stackTrace: stackTrace);
    rethrow;
  }
}