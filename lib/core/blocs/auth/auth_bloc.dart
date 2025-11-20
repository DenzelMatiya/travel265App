// lib/core/blocs/auth/auth_bloc.dart - CORRECTED VERSION ✅

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // ✅ USE PREFIX

import 'package:travel265/core/blocs/auth/auth_event.dart';
import 'package:travel265/core/blocs/auth/auth_state.dart';
import 'package:travel265/core/models/user_model.dart';
import 'package:travel265/core/services/auth_service.dart';
import 'package:travel265/core/utils/logger.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<supabase.AuthState>? _authSubscription; // ✅ Now works with prefix

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService.instance,
        super(AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthMagicLinkSent>(_onMagicLinkSent);

    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((authState) {
      // ✅ Access Supabase types with prefix
      if (authState.event == supabase.AuthChangeEvent.signedIn) {
        add(AuthCheckRequested());
      } else if (authState.event == supabase.AuthChangeEvent.signedOut) {
        emit(AuthState.unauthenticated());
      }
    }, onError: (e, s) => logger.e('auth error', error: e, stackTrace: s));
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthState.loading());

    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userModel = UserModel.fromSupabaseUser(
          id: user.id,
          email: user.email ?? '',
          userMetadata: user.userMetadata,
        );
        emit(AuthState.authenticated(userModel));
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      logger.e('Auth check failed', error: e);
      emit(AuthState.error('Authentication failed: $e'));
    }
  }

  Future<void> _onSignOutRequested(
      AuthSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthState.loading());

    try {
      await _authService.signOut();
      emit(AuthState.unauthenticated());
    } catch (e) {
      logger.e('Sign out failed', error: e);
      emit(AuthState.error('Sign out failed: $e'));
    }
  }

  Future<void> _onMagicLinkSent(
      AuthMagicLinkSent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthState.loading());

    try {
      await _authService.signInWithMagicLink(event.email);
      emit(AuthState.unauthenticated()); // Wait for callback
    } catch (e) {
      logger.e('Magic link failed', error: e);
      emit(AuthState.error('Failed to send magic link: $e'));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}