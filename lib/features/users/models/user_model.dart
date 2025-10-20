import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/value_objects/user_role.dart';

/// User model representing a user in the system
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final UserRole role;
  final bool isActive;
  final int totalPoints;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.role,
    this.isActive = true,
    this.totalPoints = 0,
    required this.createdAt,
    this.lastLoginAt,
    this.metadata,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: UserRole.fromString(map['role'] as String? ?? 'user'),
      isActive: map['isActive'] as bool? ?? true,
      totalPoints: map['totalPoints'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role.value,
      'isActive': isActive,
      'totalPoints': totalPoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    UserRole? role,
    bool? isActive,
    int? totalPoints,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      totalPoints: totalPoints ?? this.totalPoints,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, role: ${role.value}, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel &&
      other.id == id &&
      other.email == email &&
      other.role == role;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ role.hashCode;
}

