import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:travel265/core/services/auth_service.dart';
import 'package:travel265/core/theme/app_theme.dart';
import 'package:travel265/core/utils/logger.dart';
import 'package:travel265/features/dashboard/host_dashboard.dart';
import 'package:travel265/features/auth/host_register.dart';

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
  StreamSubscription<supabase.AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _checkExistingSession();
    WidgetsBinding.instance.addPostFrameCallback((_) => FocusScope.of(context).requestFocus(_emailFocusNode));
  }

  void _setupAuthListener() {
    _authSubscription = AuthService.instance.authStateChanges.listen((state) {
      if (state.event == supabase.AuthChangeEvent.signedIn && mounted && !_hasNavigated) {
        _hasNavigated = true;
        _navigateToDashboard();
      }
    }, onError: (e, s) => logger.e('auth error', error: e, stackTrace: s));
  }

  void _checkExistingSession() {
    if (AuthService.instance.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasNavigated) {
          _hasNavigated = true;
          _navigateToDashboard();
        }
      });
    }
  }

  Future<void> _navigateToDashboard() async {
    if (!mounted) return;
    await HapticFeedback.lightImpact();
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HostDashboardScreen()),
          (route) => false,
    );
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signInWithMagicLink(_emailController.text.trim());
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.mark_email_read_outlined, size: 64, color: primaryColor),
      title: const Text('Check Your Email'),
      content: Text('Magic link sent to: ${_emailController.text}'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ),
  );

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
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        title: Text('Host Login', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _Header(),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  validator: (v) => v!.trim().isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendMagicLink,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('Send Magic Link'),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HostRegisterScreen()),
                  ),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [primaryColor.withOpacity(0.15), primaryColor.withOpacity(0.05)]),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.home_work_outlined, size: 40, color: primaryColor),
        ),
        const SizedBox(height: 24),
        Text("Welcome back, Host!", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text("Enter your email to receive a secure login link", style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}