// lib/core/blocs/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthMagicLinkSent extends AuthEvent {
  final String email;
  const AuthMagicLinkSent(this.email);

  @override
  List<Object?> get props => [email];
}