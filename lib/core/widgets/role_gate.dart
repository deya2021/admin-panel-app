import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../domain/value_objects/user_role.dart';

/// Widget that conditionally renders content based on user role
class RoleGate extends ConsumerWidget {
  final UserRole minimumRole;
  final Widget child;
  final Widget? fallback;

  const RoleGate({
    Key? key,
    required this.minimumRole,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);

    return userRole.when(
      data: (role) {
        if (role != null && role.hasPermission(minimumRole)) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
      loading: () => fallback ?? const SizedBox.shrink(),
      error: (_, __) => fallback ?? const SizedBox.shrink(),
    );
  }
}

/// Widget that shows different content based on user role
class RoleBasedView extends ConsumerWidget {
  final Widget adminView;
  final Widget? managerView;
  final Widget? userView;

  const RoleBasedView({
    Key? key,
    required this.adminView,
    this.managerView,
    this.userView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);

    return userRole.when(
      data: (role) {
        if (role == null) {
          return userView ?? const SizedBox.shrink();
        }

        switch (role) {
          case UserRole.admin:
            return adminView;
          case UserRole.manager:
            return managerView ?? adminView;
          case UserRole.user:
            return userView ?? const SizedBox.shrink();
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('خطأ: $error'), // Error
      ),
    );
  }
}

/// Widget that blocks access for unauthorized users
class ProtectedRoute extends ConsumerWidget {
  final UserRole minimumRole;
  final Widget child;

  const ProtectedRoute({
    Key? key,
    required this.minimumRole,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);

    return userRole.when(
      data: (role) {
        if (role != null && role.hasPermission(minimumRole)) {
          return child;
        }
        return _AccessDeniedView(requiredRole: minimumRole);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('خطأ: $error'),
        ),
      ),
    );
  }
}

/// Access denied view
class _AccessDeniedView extends StatelessWidget {
  final UserRole requiredRole;

  const _AccessDeniedView({required this.requiredRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('غير مصرح'), // Not authorized
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'غير مصرح بالوصول', // Access denied
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'هذه الصفحة متاحة فقط ${_getRoleText(requiredRole)}', // This page is only available for
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('رجوع'), // Back
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'للمديرين'; // For admins
      case UserRole.manager:
        return 'للمشرفين والمديرين'; // For managers and admins
      case UserRole.user:
        return 'للمستخدمين'; // For users
    }
  }
}

