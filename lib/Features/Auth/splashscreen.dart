// lib/features/auth/splashscreen.dart - REFINED

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel265/core/theme/app_theme.dart'; // Import theme and primaryColor
import 'package:travel265/features/auth/role_selection_screen.dart';

/// Splash screen animation durations
class _SplashDurations {
  static const splash = Duration(seconds: 3);
  static const animationDelay = Duration(milliseconds: 200);
  static const skipButtonDelay = Duration(seconds: 1);
  static const animation = Duration(milliseconds: 800);
  static const transition = Duration(milliseconds: 400);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  bool _canSkip = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimers();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: _SplashDurations.animation,
    );
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startTimers() {
    Future.delayed(_SplashDurations.animationDelay, () {
      if (mounted) _controller.forward();
    });
    Future.delayed(_SplashDurations.skipButtonDelay, () {
      if (mounted) setState(() => _canSkip = true);
    });
    Future.delayed(_SplashDurations.splash, _navigate);
  }

  Future<void> _navigate() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    if (_canSkip) HapticFeedback.lightImpact();

    await Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
        transitionDuration: _SplashDurations.transition,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // TODO: Consider using Theme.of(context).extension<AppColors>()?.primary instead of importing primaryColor directly
    return PopScope(
      canPop: false, // Replaces deprecated WillPopScope
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: FadeTransition(
                        opacity: _fade,
                        child: _Logo(isDark: isDark),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _fade,
                      child: _Title(theme: theme, isDark: isDark),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fade,
                      child: _Tagline(theme: theme, isDark: isDark),
                    ),
                    const Spacer(),
                    _SkipButton(canSkip: _canSkip, onPressed: _navigate),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// TODO: Extract to lib/core/widgets/brand_logo.dart for reuse
class _Logo extends StatelessWidget {
  final bool isDark;
  const _Logo({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: primaryColor.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(
        Icons.travel_explore,
        size: 60,
        color: primaryColor,
        semanticLabel: 'Travel 265 logo',
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  const _Title({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      "TRAVEL 265",
      style: theme.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : Colors.black87,
      ),
      semanticsLabel: "Travel 265",
    );
  }
}

class _Tagline extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  const _Tagline({required this.theme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Your trusted way to discover and book stays in Malawi",
      style: theme.textTheme.bodyLarge?.copyWith(
        color: isDark ? Colors.white70 : Colors.grey[600],
        height: 1.4,
      ),
      textAlign: TextAlign.center,
      semanticsLabel: "Your trusted way to discover and book stays in Malawi",
    );
  }
}

class _SkipButton extends StatelessWidget {
  final bool canSkip;
  final VoidCallback onPressed;
  const _SkipButton({required this.canSkip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: canSkip ? 1 : 0,
      duration: _SplashDurations.transition,
      child: AnimatedScale(
        scale: canSkip ? 1.0 : 0.8,
        duration: _SplashDurations.transition,
        child: TextButton(
          onPressed: canSkip ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            minimumSize: const Size(64, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Skip',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}