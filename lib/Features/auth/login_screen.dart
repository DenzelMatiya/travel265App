// lib/features/auth/login_screen.dart - FIXED

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel265/core/blocs/auth/auth_bloc.dart';
import 'package:travel265/core/blocs/auth/auth_event.dart';
import 'package:travel265/core/blocs/auth/auth_state.dart';
import 'package:travel265/core/models/user_model.dart';
import 'package:travel265/core/theme/app_theme.dart';
import 'package:travel265/features/auth/password_login_screen.dart';
import 'package:travel265/features/auth/register_screen.dart';
import 'package:travel265/features/home/guest_home_screen.dart';
import 'package:travel265/features/dashboard/host_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final UserRole? intendedRole;

  const LoginScreen({
    super.key,
    this.intendedRole,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;
  bool _hasNavigated = false;

  late AuthBloc _authBloc;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _setupAuthListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  void _setupAuthListener() {
    _authSubscription = _authBloc.stream.listen((state) async {
      if (state.status == AuthStatus.authenticated && mounted && !_hasNavigated) {
        _hasNavigated = true;
        if (state.user != null) {
          await _navigateBasedOnRole(state.user!);
        }
      } else if (state.status == AuthStatus.error && mounted) {
        setState(() => _errorMessage = state.errorMessage);
      }
    });
  }

  Future<void> _navigateBasedOnRole(UserModel user) async {
    if (!mounted) return;

    // Navigate based on role
    if (user.role == UserRole.host) {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HostDashboardScreen()),
            (route) => false,
      );
    } else {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const GuestHomeScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use BLoC instead of direct service call
      _authBloc.add(AuthMagicLinkSent(_emailController.text.trim()));

      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = _getFriendlyError(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFriendlyError(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('invalid email')) return 'Enter a valid email';
    if (msg.contains('rate limit')) return 'Too many attempts. Please wait';
    if (msg.contains('network')) return 'Network error. Check connection';
    return 'Login failed. Please try again';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.mark_email_read_outlined, size: 64, color: primaryColor),
        title: Text(widget.intendedRole == UserRole.host
            ? 'Host Login Link Sent'
            : 'Login Link Sent'),
        content: Text('Check your email: ${_emailController.text}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    final isHost = widget.intendedRole == UserRole.host;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isHost ? 'Host Login' : 'Login',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
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
                _Header(isHost: isHost),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email required';
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                      return 'Invalid email format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
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
                      : Text(isHost ? 'Send Host Login Link' : 'Send Login Link'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PasswordLoginScreen(intendedRole: widget.intendedRole),
                      ),
                    );
                  },
                  child: const Text('Prefer password? Sign in with password'),
                ),
                const SizedBox(height: 32),
                _buildFooter(isHost),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isHost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => RegisterScreen(intendedRole: widget.intendedRole),
              ),
            );
          },
          child: Text(isHost ? 'Register as Host' : 'Register'),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isHost;
  const _Header({required this.isHost});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                primaryColor.withValues(alpha: 0.15),
                primaryColor.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHost ? Icons.home_work_outlined : Icons.person_outline,
            size: 40,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isHost ? 'Welcome back, Host!' : 'Welcome Back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isHost
              ? 'Enter your email to receive a secure login link'
              : 'Enter your email to continue',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}