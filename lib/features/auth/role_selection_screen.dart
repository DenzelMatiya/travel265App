// lib/features/auth/role_selection_screen.dart - UPDATED

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel265/core/theme/app_theme.dart';
import 'package:travel265/features/auth/host_login.dart';
import 'package:travel265/features/auth/host_register.dart';
import 'package:travel265/features/auth/guest_login_screen.dart';
import 'package:travel265/features/home/guest_home_screen.dart';

/// 🎯 Role Selection Screen - Entry point for all users
///
/// Options:
/// 1. Continue as Guest (browse without login)
/// 2. Guest Login (for booking)
/// 3. Host Registration
/// 4. Host Login
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
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  const _WelcomeSection(),
                  const SizedBox(height: 40),
                  _buildBrowseAsGuestOption(context),
                  const SizedBox(height: 16),
                  _buildGuestLoginOption(context),
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 32),
                  _buildHostSection(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 👤 Browse without login (limited features)
  Widget _buildBrowseAsGuestOption(BuildContext context) {
    return _RoleCard(
      icon: Icons.explore_outlined,
      title: "Browse as Guest",
      subtitle: "Explore stays without creating an account",
      color: Colors.grey.shade700,
      onTap: () => _handleSelection(context, RouteType.guestBrowse),
      showBadge: true,
      badgeText: "No Login Required",
    );
  }

  /// 🔐 Guest login (for booking)
  Widget _buildGuestLoginOption(BuildContext context) {
    return _RoleCard(
      icon: Icons.person_outline,
      title: "Sign In to Book",
      subtitle: "Login to make reservations and manage bookings",
      color: primaryColor,
      onTap: () => _handleSelection(context, RouteType.guestLogin),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'FOR HOSTS',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildHostSection(BuildContext context) {
    return Column(
      children: [
        Text(
          "List Your Property",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _RoleCard(
          icon: Icons.house_rounded,
          title: "Become a Host",
          subtitle: "Register and start earning from your property",
          color: Colors.green.shade700,
          onTap: () => _handleSelection(context, RouteType.hostRegister),
        ),
        const SizedBox(height: 12),
        _RoleCard(
          icon: Icons.login_outlined,
          title: "Host Login",
          subtitle: "Access your host dashboard",
          color: Colors.orange.shade700,
          onTap: () => _handleSelection(context, RouteType.hostLogin),
        ),
      ],
    );
  }

  Future<void> _handleSelection(BuildContext context, RouteType type) async {
    try {
      await HapticFeedback.lightImpact();
      final route = _getRouteForType(type);
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

  Widget _getRouteForType(RouteType type) {
    switch (type) {
      case RouteType.guestBrowse:
        return const GuestHomeScreen(); // Browse without auth
      case RouteType.guestLogin:
        return const GuestLoginScreen();
      case RouteType.hostRegister:
        return const HostRegisterScreen();
      case RouteType.hostLogin:
        return const HostLoginScreen();
    }
  }
}

enum RouteType { guestBrowse, guestLogin, hostRegister, hostLogin }

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
          "Discover amazing stays across Malawi",
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

/// Unified role selection card
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showBadge;
  final String? badgeText;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.showBadge = false,
    this.badgeText,
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
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (showBadge && badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ],
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