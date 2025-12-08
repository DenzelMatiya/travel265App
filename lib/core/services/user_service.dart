// lib/core/services/user_service.dart - FIXED

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel265/core/models/user_model.dart';
import 'package:logger/logger.dart';

final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

/// 🎭 User Role Model
class UserRoleModel {
  final String userId;
  final UserRole role;
  final bool hasCompletedProfile;
  final DateTime createdAt;

  UserRoleModel({
    required this.userId,
    required this.role,
    required this.hasCompletedProfile,
    required this.createdAt,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      userId: json['user_id'],
      role: UserRole.values.firstWhere(
            (r) => r.name == json['role'],
        orElse: () => UserRole.guest,
      ),
      hasCompletedProfile: json['has_completed_profile'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// 👤 User Profile & Role Management
class UserService {
  UserService._internal();
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  static UserService get instance => _instance;

  final SupabaseClient _client = Supabase.instance.client;

  /// 🎯 Get user role from database
  Future<UserRoleModel?> getUserRole(String userId) async {
    try {
      final response = await _client
          .from('user_roles')
          .select()
          .eq('user_id', userId)
          .single();

      return UserRoleModel.fromJson(response);
    } catch (e) {
      _logger.w('User role not found for $userId');
      return null;
    }
  }

  /// 🎯 Get complete user model
  Future<UserModel?> getUser(String userId) async {
    try {
      // Get auth user
      final authUser = _client.auth.currentUser;
      if (authUser == null || authUser.id != userId) {
        return null;
      }

      // Get role
      final roleModel = await getUserRole(userId);

      return UserModel.fromSupabaseUser(
        id: authUser.id,
        email: authUser.email ?? '',
        role: roleModel?.role ?? UserRole.guest,
        userMetadata: authUser.userMetadata,
      );
    } catch (e) {
      _logger.e('Failed to get user', error: e);
      return null;
    }
  }

  /// 📝 Create user role for new user
  Future<void> createUserRole(String userId, UserRole role) async {
    try {
      await _client.from('user_roles').insert({
        'user_id': userId,
        'role': role.name,
        'has_completed_profile': false,
      });
      _logger.i('✅ User role created: $role');
    } catch (e) {
      _logger.e('❌ Failed to create user role', error: e);
      throw Exception('Failed to create user role: $e');
    }
  }

  /// 🔄 Update user role
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _client
          .from('user_roles')
          .update({'role': role.name})
          .eq('user_id', userId);
      _logger.i('✅ User role updated: $role');
    } catch (e) {
      _logger.e('❌ Failed to update user role', error: e);
      throw Exception('Failed to update user role: $e');
    }
  }

  /// 📝 Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(data: data),
      );
      _logger.i('✅ User profile updated');
    } catch (e) {
      _logger.e('❌ Failed to update profile', error: e);
      throw Exception('Failed to update profile: $e');
    }
  }

  /// 🧹 Delete user account
  Future<void> deleteAccount(String userId) async {
    try {
      await _client.rpc('delete_user_account', params: {'user_id': userId});
      _logger.i('✅ User account deleted');
    } catch (e) {
      _logger.e('❌ Failed to delete account', error: e);
      throw Exception('Failed to delete account: $e');
    }
  }
}