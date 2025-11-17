// lib/features/auth/splashscreen.dart

// This screen shows a branded intro for 3 seconds, then moves to role selection.
// It's the first screen users see — so it's designed to feel premium and smooth.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel265/features/auth/role_selection_screen.dart';
import '../../material.dart';

// How long the splash screen stays visible before auto-advancing
const Duration splashDuration = Duration(seconds: 3);

// Delays for animations and interactions
const Duration _kAnimationStartDelay = Duration(milliseconds: 200); // Logo appears quickly
const Duration _kSkipButtonDelay = Duration(seconds: 1);           // "Skip" appears after 1s
const Duration _kAnimationDuration = Duration(milliseconds: 800);   // Logo animation speed
const Duration _kTransitionDuration = Duration(milliseconds: 400);  // Screen fade-out speed

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  // Animation controller for logo entrance
  late final AnimationController _controller;
  late final Animation<double> _scale; // Logo grows from small to full size
  late final Animation<double> _fade;  // Logo fades in

  // UI state flags
  bool _canSkip = false;       // Has the "Skip" button appeared?
  bool _hasNavigated = false;  // Have we already gone to the next screen?
  bool _isDisposed = false;    // Prevent actions after screen is closed

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scheduleAnimations();
    _scheduleNavigation(); // Start 3-second timer
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );

    // Logo scales up with a "bounce" effect (easeOutBack)
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Logo fades in smoothly
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _scheduleAnimations() {
    // Start logo animation after a short delay
    Future.delayed(_kAnimationStartDelay, () {
      if (mounted && !_isDisposed) _controller.forward();
    });

    // Show "Skip" button after 1 second
    Future.delayed(_kSkipButtonDelay, () {
      if (mounted && !_isDisposed) {
        setState(() => _canSkip = true);
      }
    });
  }

  void _scheduleNavigation() {
    // After 3 seconds, go to next screen
    Future.delayed(splashDuration, _navigate);
  }

  void _navigate() {
    // Safety: only navigate once
    if (_hasNavigated || _isDisposed || !mounted) return;
    _hasNavigated = true;

    // Gentle vibration when skipping (optional polish)
    if (_canSkip) {
      HapticFeedback.lightImpact();
    }

    // Replace splash screen with RoleSelectionScreen (no back arrow)
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
        transitionDuration: _kTransitionDuration,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose(); // Free animation resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WillPopScope(
      // Prevent Android back button from exiting the app during splash
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          // Adjust status bar icons: white in dark mode, black in light mode
          value: isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    ScaleTransition(
                      scale: _scale,
                      child: FadeTransition(
                        opacity: _fade,
                        child: Container(
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
                            // Subtle shadow in light mode only
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Semantics(
                            label: 'App logo: Travel Explore',
                            child: Icon(
                              Icons.travel_explore,
                              size: 60,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // App name with bold styling
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        "TRAVEL 265",
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ) ??
                            const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                        semanticsLabel: "Travel 265",
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tagline explaining the app's purpose
                    FadeTransition(
                      opacity: _fade,
                      child: Text(
                        "Your trusted way to discover and book stays in Malawi",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark
                              ? Colors.white70
                              : Colors.grey[600],
                          height: 1.4,
                        ) ??
                            const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: Colors.grey,
                            ),
                        textAlign: TextAlign.center,
                        semanticsLabel:
                        "Your trusted way to discover and book stays in Malawi",
                      ),
                    ),
                    const Spacer(),

                    // Skip button (appears after 1 second)
                    ExcludeSemantics(
                      excluding: !_canSkip, // Hide from accessibility until visible
                      child: _buildSkipButton(theme),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(ThemeData theme) {
    return AnimatedOpacity(
      opacity: _canSkip ? 1 : 0,
      duration: _kTransitionDuration,
      child: AnimatedScale(
        scale: _canSkip ? 1.0 : 0.8,
        duration: _kTransitionDuration,
        child: TextButton(
          onPressed: _canSkip ? _navigate : null, // Disabled until ready
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