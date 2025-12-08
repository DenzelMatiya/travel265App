// lib/core/blocs/auth/auth_bloc.dart - FIXED

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:travel265/core/blocs/auth/auth_event.dart';
import 'package:travel265/core/blocs/auth/auth_state.dart';
import 'package:travel265/core/models/user_model.dart';
import 'package:travel265/core/services/auth_service.dart';
import 'package:travel265/core/services/user_service.dart';
import 'package:travel265/core/utils/logger.dart' as app_logger;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserService _userService;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthBloc({
    AuthService? authService,
    UserService? userService,
  })  : _authService = authService ?? AuthService.instance,
        _userService = userService ?? UserService.instance,
        super(AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthMagicLinkSent>(_onMagicLinkSent);
    on<AuthPasswordLoginRequested>(_onPasswordLoginRequested);
    on<AuthPasswordSignUpRequested>(_onPasswordSignUpRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);

    _setupAuthListener();
  }

  void _setupAuthListener() {
    app_logger.logger.d('🎧 Setting up Supabase auth listener');

    _authSubscription = _authService.authStateChanges.listen(
          (supabaseState) async {
        app_logger.logger.d('🔔 Supabase auth event: ${supabaseState.event}');

        // On password signup, create role entry
        if (supabaseState.event == supabase.AuthChangeEvent.signedIn) {
          final user = supabaseState.session?.user;
          if (user != null) {
            final existingRole = await _userService.getUserRole(user.id);
            if (existingRole == null) {
              // New user - default to guest
              await _userService.createUserRole(user.id, UserRole.guest);
            }
          }
        }

        add(const AuthCheckRequested());
      },
      onError: (error, stackTrace) {
        app_logger.logger.e('🔥 Auth stream error', error: error, stackTrace: stackTrace);
        add(const AuthCheckRequested());
      },
      cancelOnError: false,
    );
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    app_logger.logger.d('🔍 Checking authentication status');
    emit(AuthState.loading());

    try {
      final authUser = _authService.currentUser;

      if (authUser == null) {
        app_logger.logger.i('❌ No user session found');
        emit(AuthState.unauthenticated());
        return;
      }

      // Get user role from database
      final userRole = await _userService.getUserRole(authUser.id);

      if (userRole == null) {
        // User exists in auth but not in user_roles - create guest entry
        await _userService.createUserRole(authUser.id, UserRole.guest);
        final newRole = await _userService.getUserRole(authUser.id);

        final userModel = UserModel.fromSupabaseUser(
          id: authUser.id,
          email: authUser.email ?? '',
          role: newRole?.role ?? UserRole.guest,
          userMetadata: authUser.userMetadata,
        );

        emit(AuthState.authenticated(userModel));
      } else {
        final userModel = UserModel.fromSupabaseUser(
          id: authUser.id,
          email: authUser.email ?? '',
          role: userRole.role,
          userMetadata: authUser.userMetadata,
        );

        emit(AuthState.authenticated(userModel));
      }
    } catch (error, stackTrace) {
      app_logger.logger.e('🔥 Auth check failed', error: error, stackTrace: stackTrace);
      emit(AuthState.error('Authentication check failed: $error'));
    }
  }

  Future<void> _onSignOutRequested(
      AuthSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    app_logger.logger.i('🚪 Sign out requested');
    emit(AuthState.loading());

    try {
      await _authService.signOut();
      app_logger.logger.i('✅ Sign out successful');
      emit(AuthState.unauthenticated());
    } catch (error, stackTrace) {
      app_logger.logger.e('🔥 Sign out failed', error: error, stackTrace: stackTrace);
      emit(AuthState.error('Sign out failed: $error'));
    }
  }

  Future<void> _onMagicLinkSent(
      AuthMagicLinkSent event,
      Emitter<AuthState> emit,
      ) async {
    app_logger.logger.i('📧 Magic link requested for: ${event.email}');
    emit(AuthState.loading());

    try {
      await _authService.signInWithMagicLink(event.email);
      app_logger.logger.i('✅ Magic link sent successfully');
      emit(AuthState.unauthenticated());
    } catch (error, stackTrace) {
      app_logger.logger.e('🔥 Magic link failed', error: error, stackTrace: stackTrace);
      emit(AuthState.error('Failed to send magic link: $error'));
    }
  }

  Future<void> _onPasswordLoginRequested(
      AuthPasswordLoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    app_logger.logger.i('🔐 Password login requested for: ${event.email}');
    emit(AuthState.loading());

    try {
      final response = await _authService.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        app_logger.logger.i('✅ Password login successful: ${response.user?.email}');

        // Get user role
        final userRole = await _userService.getUserRole(response.user!.id);

        final userModel = UserModel.fromSupabaseUser(
          id: response.user!.id,
          email: response.user!.email ?? '',
          role: userRole?.role ?? UserRole.guest,
          userMetadata: response.user!.userMetadata,
        );

        emit(AuthState.authenticated(userModel));
      } else {
        throw Exception('Login succeeded but no user returned');
      }
    } catch (error, stackTrace) {
      app_logger.logger.e('🔥 Password login failed', error: error, stackTrace: stackTrace);
      emit(AuthState.error('Login failed: $error'));
    }
  }

  Future<void> _onPasswordSignUpRequested(
      AuthPasswordSignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    app_logger.logger.i('📝 Sign up requested for: ${event.email}');
    emit(AuthState.loading());

    try {
      final response = await _authService.signUp(
        email: event.email,
        password: event.password,
        metadata: event.metadata,
      );

      if (response.user != null) {
        app_logger.logger.i('✅ Sign up successful: ${response.user?.email}');

        // Create user role entry
        final role = event.metadata?['role'] == 'host' ? UserRole.host : UserRole.guest;
        await _userService.createUserRole(response.user!.id, role);

        emit(AuthState.unauthenticated());
      } else {
        throw Exception('Sign up succeeded but no user returned');
      }
    } catch (error, stackTrace) {
      app_logger.logger.e('🔥 Sign up failed', error: error, stackTrace: stackTrace);
      emit(AuthState.error('Sign up failed: $error'));
    }
  }

  Future<void> _onPasswordResetRequested(
      AuthPasswordResetRequested event,
      Emitter<AuthState> emit,
      ) async {
    app_logger.logger.i('🔄 Password reset requested for: ${event.email}');
    emit(AuthState.loading());

    try {
      await _authService.resetPassword(event.email);
      app_logger.logger.i('✅ Password reset email sent');
      emit(AuthState.unauthenticated());
    } catch (error, stackTrace) {
      app_logger.logger.e('🔥 Password reset failed', error: error, stackTrace: stackTrace);
      emit(AuthState.error('Password reset failed: $error'));
    }
  }

  @override
  Future<void> close() {
    app_logger.logger.d('🧹 Closing AuthBloc and canceling subscriptions');
    _authSubscription?.cancel();
    return super.close();
  }
}