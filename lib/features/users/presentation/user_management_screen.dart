import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/extensions/user_role_extensions.dart';
import '../../../domain/value_objects/user_role.dart';
import '../providers/user_providers.dart';
import '../models/user_model.dart';

/// User Management Screen for admins to manage users and roles
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';
  UserRole? _filterRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(usersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'), // User Management
        actions: [
          // Filter by role
          PopupMenuButton<UserRole?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'تصفية حسب الدور', // Filter by role
            onSelected: (role) {
              setState(() => _filterRole = role);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('الكل'), // All
              ),
              PopupMenuItem(
                value: UserRole.admin,
                child: Text(UserRole.admin.displayName),
              ),
              PopupMenuItem(
                value: UserRole.manager,
                child: Text(UserRole.manager.displayName),
              ),
              PopupMenuItem(
                value: UserRole.user,
                child: Text(UserRole.user.displayName),
              ),
            ],
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث', // Refresh
            onPressed: () {
              ref.invalidate(usersStreamProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث عن مستخدم...', // Search for user...
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // Stats cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'إجمالي المستخدمين', // Total Users
                    value: ref.watch(totalUsersCountProvider).toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'المديرون', // Admins
                    value: ref.watch(adminCountProvider).toString(),
                    icon: Icons.admin_panel_settings,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'المشرفون', // Managers
                    value: ref.watch(managerCountProvider).toString(),
                    icon: Icons.supervisor_account,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Users list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                // Apply filters
                var filteredUsers = users;

                if (_filterRole != null) {
                  filteredUsers = filteredUsers
                      .where((user) => user.role == _filterRole)
                      .toList();
                }

                if (_searchQuery.isNotEmpty) {
                  filteredUsers = filteredUsers.where((user) {
                    return user.email.toLowerCase().contains(_searchQuery) ||
                        (user.displayName?.toLowerCase().contains(_searchQuery) ?? false);
                  }).toList();
                }

                if (filteredUsers.isEmpty) {
                  return const EmptyView(
                    message: 'لا يوجد مستخدمون', // No users
                    icon: Icons.people_outline,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _UserCard(user: user);
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => ErrorView(
                error: error.toString(),
                onRetry: () => ref.invalidate(usersStreamProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// User card widget
class _UserCard extends ConsumerWidget {
  final UserModel user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.role.color,
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(
                  user.email[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        title: Text(
          user.displayName ?? user.email,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.displayName != null) ...[
              const SizedBox(height: 4),
              Text(user.email),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.role.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: TextStyle(
                      color: user.role.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.isActive ? 'نشط' : 'غير نشط', // Active / Inactive
                    style: TextStyle(
                      color: user.isActive ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            final repository = ref.read(userRepositoryProvider);

            switch (value) {
              case 'change_role':
                await _showChangeRoleDialog(context, ref, user);
                break;
              case 'toggle_status':
                try {
                  await repository.updateUserActiveStatus(user.id, !user.isActive);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(user.isActive ? 'تم تعطيل المستخدم' : 'تم تفعيل المستخدم'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                break;
              case 'delete':
                await _showDeleteDialog(context, ref, user);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'change_role',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz),
                  SizedBox(width: 8),
                  Text('تغيير الدور'), // Change role
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(user.isActive ? Icons.block : Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'تعطيل' : 'تفعيل'), // Deactivate / Activate
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)), // Delete
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangeRoleDialog(BuildContext context, WidgetRef ref, UserModel user) async {
    UserRole? selectedRole = user.role;

    final result = await showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير دور المستخدم'), // Change user role
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: UserRole.values.map((role) {
              return RadioListTile<UserRole>(
                title: Text(role.displayName),
                value: role,
                groupValue: selectedRole,
                onChanged: (value) {
                  setState(() => selectedRole = value);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'), // Cancel
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedRole),
            child: const Text('تأكيد'), // Confirm
          ),
        ],
      ),
    );

    if (result != null && result != user.role && context.mounted) {
      try {
        final repository = ref.read(userRepositoryProvider);
        await repository.updateUserRole(user.id, result);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تغيير الدور بنجاح'), // Role changed successfully
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'), // Confirm deletion
        content: Text('هل أنت متأكد من حذف المستخدم ${user.email}؟'), // Are you sure you want to delete user?
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'), // Cancel
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'), // Delete
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repository = ref.read(userRepositoryProvider);
        await repository.deleteUser(user.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف المستخدم بنجاح'), // User deleted successfully
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

