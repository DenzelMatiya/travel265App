// lib/core/blocs/auth/auth_event.dart - COMPLETE VERSION

import 'package:equatable/equatable.dart';

/// 🎯 Authentication Events - All possible user interactions
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 🔍 Check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// 🚪 Sign out current user
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// 📧 Send magic link to email
class AuthMagicLinkSent extends AuthEvent {
  final String email;

  const AuthMagicLinkSent(this.email);

  @override
  List<Object?> get props => [email];
}

// Add to lib/core/blocs/auth/auth_event.dart

/// 🔐 Login with email/password
class AuthPasswordLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthPasswordLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// 📝 Sign up with email/password
class AuthPasswordSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final Map<String, dynamic>? metadata;

  const AuthPasswordSignUpRequested({
    required this.email,
    required this.password,
    this.metadata,
  });

  @override
  List<Object?> get props => [email, password, metadata];
}

/// 🔄 Request password reset
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}