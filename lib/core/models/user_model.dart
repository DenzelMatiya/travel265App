//lib/core/models/user_model.dart
import 'package:equatable/equatable.dart';

enum UserRole { guest, host, admin }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final UserRole role;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role = UserRole.guest,
    required this.createdAt,
    this.metadata,
  });

  // Factory for Supabase auth user
  factory UserModel.fromSupabaseUser({
    required String id,
    required String email,
    UserRole role = UserRole.guest,
    Map<String, dynamic>? userMetadata,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: userMetadata?['full_name'],
      phoneNumber: userMetadata?['phone_number'],
      role: role,
      createdAt: DateTime.now(),
      metadata: userMetadata,
    );
  }

  @override
  List<Object?> get props => [id, email, role];

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}