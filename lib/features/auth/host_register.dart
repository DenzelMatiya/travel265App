// lib/features/auth/host_register.dart - REFINED

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel265/core/services/auth_service.dart';
import 'package:travel265/core/theme/app_theme.dart';
import 'package:logger/logger.dart';

// TODO: Extract to core/utils/logger.dart
final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

/// Host registration screen using magic link authentication.
///
/// Allows new hosts to register with their email address. A magic link
/// is sent to their inbox for passwordless authentication.
class HostRegisterScreen extends StatefulWidget {
  const HostRegisterScreen({super.key});

  @override
  State<HostRegisterScreen> createState() => _HostRegisterScreenState();
}

class _HostRegisterScreenState extends State<HostRegisterScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    // Focus email field automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      await AuthService.instance.signInWithMagicLink(_emailController.text.trim());
      _showSuccessDialog();
    } catch (e) {
      _logger.e('Magic link send failed', error: e);
      setState(() {
        _emailError = _getFriendlyErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getFriendlyErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment';
    }
    if (message.contains('network')) {
      return 'Network error. Please check your connection';
    }
    return 'Failed to send link. Please try again';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.email_outlined, size: 48, color: primaryColor),
        title: const Text('Check Your Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We\'ve sent a magic link to:'),
            const SizedBox(height: 8),
            Text(
              _emailController.text.trim(),
              style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 12),
            const Text('Click the link in that email to continue registration.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(theme),
                  const SizedBox(height: 40),
                  _buildEmailField(theme),
                  if (_emailError != null) ...[
                    const SizedBox(height: 8),
                    _buildErrorText(),
                  ],
                  const Spacer(),
                  _buildSendButton(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.house_rounded, size: 64, color: primaryColor),
        const SizedBox(height: 16),
        Text(
          'List Your Property',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start hosting guests and earning income today',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'host@example.com',
        prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: _emailError,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(value.trim())) {
          return 'Enter a valid email address';
        }
        return null;
      },
      onFieldSubmitted: (_) => _sendMagicLink(),
    );
  }

  Widget _buildErrorText() {
    return Text(
      _emailError!,
      style: TextStyle(color: Colors.red.shade700, fontSize: 12),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _sendMagicLink,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Text(
        'Send Magic Link',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'We\'ll send you a secure link to verify your email. No password needed!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}