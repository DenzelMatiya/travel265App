// lib/features/auth/role_selection_screen.dart

// This screen lets users choose how they want to use the app:
// - As a GUEST (browse and book stays)
// - As a HOST (list properties for rent)
//
// Since listings depend on hosts, we emphasize host onboarding.
// Note: In the future, guest users may see "no listings available"
// until hosts create properties.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel265/features/auth/host_login.dart';
import 'package:travel265/features/auth/host_register.dart';
import 'package:travel265/features/home/guest_home_screen.dart';
import '../../../material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  // Navigate to a new screen with haptic feedback (subtle vibration)
  void _navigateTo<T extends Widget>(BuildContext context, T screen) {
    HapticFeedback.lightImpact(); // Optional polish
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey[600];

    // Set status bar icons (dark in light mode, light in dark mode)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _WelcomeSection(
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                ),
                const SizedBox(height: 40),
                // Guest option
                _RoleCard(
                  icon: Icons.person_outline,
                  title: "Continue as Guest",
                  subtitle: "Browse and book unique stays across Malawi",
                  color: primaryColor,
                  onTap: () => _navigateTo(context, const GuestHomeScreen()),
                ),
                const SizedBox(height: 20),
                // Host section header
                Text(
                  "Hosting on TRAVEL 265",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ) ??
                      const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 10),
                // New Host option
                _HostOptionCard(
                  icon: Icons.house_rounded,
                  title: "New Host? Create Listing",
                  subtitle: "Register and list your property in minutes",
                  color: Colors.green.shade700,
                  onTap: () => _navigateTo(context, const HostRegisterScreen()),
                ),
                const SizedBox(height: 10),
                // Existing Host option
                _HostOptionCard(
                  icon: Icons.login_outlined,
                  title: "Existing Host? Access Account",
                  subtitle: "Log in with magic link to manage your listings",
                  color: Colors.orange.shade700,
                  onTap: () => _navigateTo(context, const HostLoginScreen()),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS BELOW ARE WELL-WRITTEN; ONLY MINOR TWEAKS MADE ---

class _WelcomeSection extends StatelessWidget {
  final Color textColor;
  final Color? subtitleColor;

  const _WelcomeSection({
    required this.textColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // App logo
        Container(
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
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: const Icon(
            Icons.travel_explore,
            size: 60,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        // Welcome title
        Text(
          "Welcome to TRAVEL 265",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
            height: 1.2,
          ) ??
              const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 12),
        // Subtitle
        Text(
          "How would you like to use our platform?",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: subtitleColor,
            height: 1.4,
            letterSpacing: 0.1,
          ) ??
              const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}

// Main role card (used for Guest)
class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => __RoleCardState();
}

class __RoleCardState extends State<_RoleCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails details) => setState(() => _isPressed = false);
  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: _isPressed ? 0.98 : 1.0,
      child: Card(
        elevation: isDark ? 2 : 6,
        shadowColor: isDark ? Colors.black54 : widget.color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: BorderRadius.circular(20),
          splashColor: widget.color.withOpacity(0.2),
          highlightColor: widget.color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(minHeight: 80),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.15),
                        widget.color.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 28,
                    color: widget.color,
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.2,
                        ) ??
                            const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          height: 1.4,
                          letterSpacing: 0.25,
                        ) ??
                            const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isPressed
                        ? widget.color.withOpacity(0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: _isPressed ? widget.color : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Smaller card for host options (Register/Login)
class _HostOptionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HostOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HostOptionCard> createState() => _HostOptionCardState();
}

class _HostOptionCardState extends State<_HostOptionCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails details) => setState(() => _isPressed = false);
  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      scale: _isPressed ? 0.98 : 1.0,
      child: Card(
        elevation: isDark ? 2 : 4,
        shadowColor: isDark ? Colors.black54 : widget.color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: BorderRadius.circular(16),
          splashColor: widget.color.withOpacity(0.2),
          highlightColor: widget.color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(minHeight: 60),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 24,
                  color: widget.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ) ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ) ??
                            const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}