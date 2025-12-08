// lib/core/widgets/auth_wrapper.dart - PRODUCTION READY

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel265/core/blocs/auth/auth_bloc.dart';
import 'package:travel265/core/blocs/auth/auth_event.dart';
import 'package:travel265/core/blocs/auth/auth_state.dart';
import 'package:travel265/core/models/user_model.dart';
import 'package:travel265/core/theme/app_theme.dart';
import 'package:travel265/features/auth/role_selection_screen.dart';
import 'package:travel265/features/home/guest_home_screen.dart';
import 'package:travel265/features/dashboard/host_dashboard.dart';

/// 🛡️ **AuthWrapper - Routes users based on authentication state**
///
/// **Purpose:**
/// - Listens to auth state changes
/// - Routes authenticated users to their appropriate screen
/// - Routes unauthenticated users to role selection
/// - Shows loading during auth checks
///
/// **Usage in main.dart:**
/// ```dart
/// home: BlocProvider(
///   create: (_) => AuthBloc()..add(const AuthCheckRequested()),
///   child: const AuthWrapper(),
/// )
/// ```
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle errors with snackbar
        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Authentication error'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const _LoadingScreen();

          case AuthStatus.authenticated:
            if (state.user != null) {
              return _getScreenForRole(state.user!.role);
            }
            return const RoleSelectionScreen();

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const RoleSelectionScreen();
        }
      },
    );
  }

  /// Route users to appropriate screen based on role
  Widget _getScreenForRole(UserRole role) {
    switch (role) {
      case UserRole.guest:
        return const GuestHomeScreen();
      case UserRole.host:
        return const HostDashboardScreen();
      case UserRole.admin:
      // TODO: Create admin dashboard
        return const HostDashboardScreen();
    }
  }
}

/// 🔄 Loading Screen
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              child: Icon(
                Icons.travel_explore,
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔐 **Protected Route Wrapper**
///
/// **Usage:**
/// Wrap any screen that requires authentication
///
/// ```dart
/// ProtectedRoute(
///   allowedRoles: [UserRole.host],
///   child: HostDashboardScreen(),
///   fallback: UpgradeToHostScreen(), // Optional
/// )
/// ```
class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;
  final Widget? fallback;

  const ProtectedRoute({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Not authenticated
        if (state.status != AuthStatus.authenticated) {
          return const RoleSelectionScreen();
        }

        // Check if user has required role
        if (state.user != null && allowedRoles.contains(state.user!.role)) {
          return child;
        }

        // Show fallback or access denied
        return fallback ?? _AccessDeniedScreen(requiredRoles: allowedRoles);
      },
    );
  }
}

/// ❌ Access Denied Screen
class _AccessDeniedScreen extends StatelessWidget {
  final List<UserRole> requiredRoles;

  const _AccessDeniedScreen({required this.requiredRoles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block,
                  size: 50,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You need ${_formatRoles(requiredRoles)} access to view this page.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRoles(List<UserRole> roles) {
    if (roles.length == 1) {
      return roles.first.name;
    }
    return roles.map((r) => r.name).join(' or ');
  }
}