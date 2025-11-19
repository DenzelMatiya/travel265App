// lib/features/auth/role_selection_screen.dart - REFINED

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel265/core/theme/app_theme.dart';
import 'package:travel265/features/auth/host_login.dart';
import 'package:travel265/features/auth/host_register.dart';
import 'package:travel265/features/home/guest_home_screen.dart';

/// Screen for users to select their role (Guest, New Host, or Existing Host)
/// This is the first screen after splash and determines the navigation flow.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const _WelcomeSection(),
                const SizedBox(height: 40),
                _buildGuestOption(context),
                const SizedBox(height: 20),
                _buildHostSection(context),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestOption(BuildContext context) {
    return _RoleCard(
      icon: Icons.person_outline,
      title: "Continue as Guest",
      subtitle: "Browse and book unique stays across Malawi",
      color: primaryColor,
      onTap: () => _handleSelection(context, Role.guest),
    );
  }

  Widget _buildHostSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          "Hosting on TRAVEL 265",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _RoleCard(
          icon: Icons.house_rounded,
          title: "New Host? Create Listing",
          subtitle: "Register and list your property in minutes",
          color: Colors.green.shade700,
          onTap: () => _handleSelection(context, Role.hostNew),
        ),
        const SizedBox(height: 10),
        _RoleCard(
          icon: Icons.login_outlined,
          title: "Existing Host? Access Account",
          subtitle: "Log in with magic link to manage your listings",
          color: Colors.orange.shade700,
          onTap: () => _handleSelection(context, Role.hostExisting),
        ),
      ],
    );
  }

  Future<void> _handleSelection(BuildContext context, Role role) async {
    try {
      // Add haptic feedback for better UX
      await HapticFeedback.lightImpact();

      final route = _getRouteForRole(role);
      await Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => route,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (e) {
      _showError(context, e);
    }
  }

  void _showError(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Unable to navigate. Please try again.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _getRouteForRole(Role role) {
    switch (role) {
      case Role.guest:
        return GuestHomeScreen();
      case Role.hostNew:
        return HostRegisterScreen();
      case Role.hostExisting:
        return HostLoginScreen();
    }
  }
}

/// User roles for navigation and access control
enum Role { guest, hostNew, hostExisting }

/// Welcome section with logo and introductory text
class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        _buildLogo(isDark),
        const SizedBox(height: 24),
        Text(
          "Welcome to TRAVEL 265",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "How would you like to use our platform?",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.white70 : Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(bool isDark) {
    // TODO: Extract to core/widgets/brand_logo.dart for reuse across screens
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
              offset: const Offset(0, 2),
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

/// Unified role selection card with consistent styling
class _RoleCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 2 : 6,
      shadowColor: isDark ? Colors.black54 : color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(minHeight: 80),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              _buildContent(theme, isDark),
              _buildArrow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 28, color: color),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      size: 16,
      color: color,
    );
  }
}