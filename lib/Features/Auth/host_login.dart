// lib/features/auth/host_login.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel265/features/auth/host_register.dart';
import 'package:travel265/features/listings/host_dashboard.dart';
import 'package:travel265/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../material.dart';

// Corrected DisposableAnnotatedRegion Widget
class DisposableAnnotatedRegion extends StatefulWidget {
  final SystemUiOverlayStyle value;
  final Widget child;
  const DisposableAnnotatedRegion({
    required this.value,
    required this.child,
    super.key,
  });

  // The createState method returns a State object for this StatefulWidget.
  @override
  State<DisposableAnnotatedRegion> createState() => _DisposableAnnotatedRegionState();
}

// The State class holds the mutable state for the StatefulWidget.
class _DisposableAnnotatedRegionState extends State<DisposableAnnotatedRegion> {
  @override
  Widget build(BuildContext context) {
    // The build method returns the widget tree for this state.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: widget.value, // Access the value passed to the StatefulWidget via 'widget'
      child: widget.child, // Access the child passed to the StatefulWidget via 'widget'
    );
  }

  @override
  void dispose() {
    // Reset to a neutral, light-friendly default when this widget is removed from the tree.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose(); // Always call super.dispose()
  }
}

class HostLoginScreen extends StatefulWidget {
  const HostLoginScreen({super.key});

  @override
  State<HostLoginScreen> createState() => _HostLoginScreenState();
}

class _HostLoginScreenState extends State<HostLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _authService = SupabaseAuthService(); // Use the new service instance

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes to navigate after magic link login
    // Ensure the stream subscription is cancelled when the widget is disposed
    // For simplicity here, but consider using WidgetsBindingObserver or StreamSubscription.dispose()
    _authService.authStateStream.listen((AuthState state) { // AuthState should now be recognized
      if (state.event == AuthChangeEvent.signedIn) { // AuthChangeEvent should now be recognized
        // User successfully authenticated via magic link
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() {
    if (mounted) { // Check if the widget is still in the tree
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HostDashboardScreen()),
      );
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Please enter your email address.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the corrected service method (no redirect URL passed here)
      await _authService.signInWithMagicLink(email);
      _showSnack(
          'A magic link has been sent to your email. Please check your inbox and click the link to log in.',
          isError: false);
      // Note: The actual navigation happens in the authStateStream listener
      // when the user clicks the link and the session is established.
    } catch (e) {
      // Handle specific errors if needed, e.g., invalid email format, rate limits
      _showSnack('Failed to send magic link: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return DisposableAnnotatedRegion( // Use the corrected widget
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* --------------------  header  -------------------- */
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.15),
                            primaryColor.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.home_work_outlined,
                        size: 24,
                        color: primaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Help & Support"),
                          content: const Text(
                              "For assistance with host account login, please contact our support team at support@travel265.com or call +265 123 456 789."),
                          actions: [
                            TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text("Close"))
                          ],
                        ),
                      ),
                      child: Text(
                        "Help",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                /* --------------------  welcome  -------------------- */
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, Host!",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Enter your email to receive a login link",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                /* --------------------  form  -------------------- */
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.email],
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                          return null;
                        },
                        decoration: _inputDecoration(
                          context,
                          'Email',
                          Icons.email_outlined,
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendMagicLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Send Login Link',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /* --------------------  footer  -------------------- */
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have a host account? ",
                      style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey[600]),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HostRegisterScreen()),
                      ),
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      BuildContext context,
      String label,
      IconData icon,
      Color primaryColor,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.grey),
      filled: true,
      fillColor: isDark ? Colors.grey[850] : Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}