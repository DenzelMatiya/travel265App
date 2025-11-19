// lib/features/auth/host_login.dart - FIXED & PRODUCTION READY

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:travel265/core/services/auth_service.dart';
import 'package:travel265/core/theme/app_theme.dart';
import 'package:travel265/features/dashboard/host_dashboard.dart';
import 'package:travel265/features/auth/host_register.dart';
import 'package:travel265/core/utils/logger.dart';

/// Host login screen using magic link authentication.
///
/// Features:
/// - Passwordless magic link authentication
/// - Auto-focus email field
/// - Real-time auth state monitoring
/// - Proper error handling and user feedback
class HostLoginScreen extends StatefulWidget {
  const HostLoginScreen({super.key});

  @override
  State<HostLoginScreen> createState() => _HostLoginScreenState();
}

class _HostLoginScreenState extends State<HostLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNavigated = false;
  bool _magicLinkSent = false;

  // ✅ FIXED: Proper type from Supabase
  StreamSubscription<supabase.AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _checkExistingSession();
    // Auto-focus email field after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  void _setupAuthListener() {
    _authSubscription = AuthService.instance.authStateChanges.listen(
          (state) {
        // ✅ FIXED: Check for signed in event and prevent double navigation
        if (state.event == supabase.AuthChangeEvent.signedIn &&
            mounted &&
            !_hasNavigated &&
            !_magicLinkSent) {
          _hasNavigated = true;
          logger.i('✅ User signed in, navigating to dashboard');
          _navigateToDashboard();
        }
      },
      onError: (error, stackTrace) {
        logger.e('Auth stream error', error: error, stackTrace: stackTrace);
        if (mounted) {
          setState(() => _errorMessage = 'Authentication error occurred');
        }
      },
    );
  }

  void _checkExistingSession() {
    if (AuthService.instance.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasNavigated) {
          _hasNavigated = true;
          logger.i('✅ Existing session found, navigating to dashboard');
          _navigateToDashboard();
        }
      });
    }
  }

  Future<void> _navigateToDashboard() async {
    if (!mounted) return;

    await HapticFeedback.lightImpact();

    // ✅ FIXED: Use proper route replacement with error handling
    try {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HostDashboardScreen()),
            (route) => false, // Remove all previous routes
      );
    } catch (e) {
      logger.e('Navigation error', error: e);
      if (mounted) {
        setState(() => _errorMessage = 'Failed to navigate: $e');
      }
    }
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _magicLinkSent = false;
    });

    try {
      final email = _emailController.text.trim();
      logger.i('📧 Sending magic link to: $email');

      await AuthService.instance.signInWithMagicLink(email);

      setState(() {
        _magicLinkSent = true;
        _isLoading = false;
      });

      _showSuccessDialog();
    } catch (e) {
      logger.e('Magic link send failed', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = _getFriendlyErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  String _getFriendlyErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('invalid email') || message.contains('format')) {
      return 'Please enter a valid email address';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment';
    }
    if (message.contains('network') || message.contains('timeout')) {
      return 'Network error. Please check your connection';
    }
    if (message.contains('user not found')) {
      return 'No account found with this email';
    }
    return 'Failed to send link. Please try again';
  }

  void _showSuccessDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.mark_email_read_outlined, size: 64, color: primaryColor),
        title: const Text('Check Your Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('We\'ve sent a secure login link to:'),
            const SizedBox(height: 8),
            Text(
              _emailController.text.trim(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Check your inbox (and spam folder)\n'
                  '• The link expires in 10 minutes\n'
                  '• No password needed!',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear form but stay on page so user can try another email
              setState(() {
                _emailController.clear();
                _magicLinkSent = false;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Host Login',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _Header(),
                const SizedBox(height: 32),
                if (_errorMessage != null) ...[
                  _ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                if (_magicLinkSent) ...[
                  _SuccessBanner(),
                  const SizedBox(height: 16),
                ],
                _EmailField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  isLoading: _isLoading,
                  onSubmit: _sendMagicLink,
                ),
                const SizedBox(height: 24),
                _SubmitButton(
                  isLoading: _isLoading,
                  onPressed: _sendMagicLink,
                ),
                const SizedBox(height: 32),
                _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Extracted widgets for better readability

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                primaryColor.withOpacity(0.15),
                primaryColor.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.home_work_outlined, size: 40, color: primaryColor),
        ),
        const SizedBox(height: 24),
        Text(
          "Welcome back, Host!",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Enter your email to receive a secure login link",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Magic link sent! Check your email.',
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _EmailField({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: 'Email address',
        hintText: 'host@example.com',
        prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Enter your email';
        final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
        return null;
      },
      onFieldSubmitted: (_) => onSubmit(),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: isLoading
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : const Text(
        'Send Magic Link',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have a host account? ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HostRegisterScreen()),
            );
          },
          child: const Text(
            "Sign up",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}