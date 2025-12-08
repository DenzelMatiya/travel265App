//lib/core/models/user_model.dart
import 'package:equatable/equatable.dart';

enum UserRole { guest, host, admin }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final UserRole role;
  final bool hasCompletedProfile;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role = UserRole.guest,
    this.hasCompletedProfile = false,
    required this.createdAt,
    this.metadata,
  });

  // Factory for Supabase auth user
  factory UserModel.fromSupabaseUser({
    required String id,
    required String email,
    required UserRole role,
    bool hasCompletedProfile = false,
    Map<String, dynamic>? userMetadata,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: userMetadata?['full_name'],
      phoneNumber: userMetadata?['phone_number'],
      role: role,
      hasCompletedProfile: hasCompletedProfile,
      createdAt: DateTime.now(),
      metadata: userMetadata,
    );
  }

  // Factory from database (user_roles table)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'],
      email: json['email'] ?? '',
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      role: UserRole.values.firstWhere(
            (r) => r.name == json['role'],
        orElse: () => UserRole.guest,
      ),
      hasCompletedProfile: json['has_completed_profile'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'],
    );
  }

  @override
  List<Object?> get props => [id, email, role, hasCompletedProfile];

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserRole? role,
    bool? hasCompletedProfile,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      hasCompletedProfile: hasCompletedProfile ?? this.hasCompletedProfile,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}