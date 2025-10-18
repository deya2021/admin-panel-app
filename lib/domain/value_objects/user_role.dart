/// User role enum with permission hierarchy
enum UserRole {
  admin('admin', 'مدير', 3),
  manager('manager', 'مشرف', 2),
  user('user', 'مستخدم', 1);

  final String value;
  final String displayName;
  final int level;

  const UserRole(this.value, this.displayName, this.level);

  /// Check if this role has permission for a required role
  bool hasPermission(UserRole requiredRole) {
    return level >= requiredRole.level;
  }

  /// Check if this is admin role
  bool get isAdmin => this == UserRole.admin;

  /// Check if this is manager or above
  bool get isManagerOrAbove => level >= UserRole.manager.level;

  /// Check if this is regular user
  bool get isRegularUser => this == UserRole.user;

  /// Parse role from string
  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  /// Convert to string
  @override
  String toString() => value;
}

