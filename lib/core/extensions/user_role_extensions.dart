import 'package:flutter/material.dart';
import '../../domain/value_objects/user_role.dart';

/// Extension to add color property to UserRole enum
extension UserRoleColorExtension on UserRole {
  /// Get color associated with this role
  Color get color {
    switch (this) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.blue;
      case UserRole.user:
        return Colors.grey;
    }
  }
}

