import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/empty_view.dart';
import '../providers/notification_providers.dart';
import '../models/notification_model.dart';
import '../../auth/providers/auth_providers.dart';

/// Notification Center Screen for viewing and managing notifications
class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  NotificationType? _filterType;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    // Configure timeago for Arabic
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = _showUnreadOnly
        ? ref.watch(unreadNotificationsStreamProvider)
        : ref.watch(userNotificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مركز الإشعارات'), // Notification Center
        actions: [
          // Filter by type
          PopupMenuButton<NotificationType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'تصفية حسب النوع', // Filter by type
            onSelected: (type) {
              setState(() => _filterType = type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('الكل'), // All
              ),
              ...NotificationType.values.map((type) => PopupMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  )),
            ],
          ),
          // Toggle unread only
          IconButton(
            icon: Icon(
              _showUnreadOnly ? Icons.mark_email_read : Icons.mark_email_unread,
            ),
            tooltip: _showUnreadOnly
                ? 'عرض الكل'
                : 'غير المقروءة فقط', // Show all / Unread only
            onPressed: () {
              setState(() => _showUnreadOnly = !_showUnreadOnly);
            },
          ),
          // Mark all as read
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'تعليم الكل كمقروء', // Mark all as read
            onPressed: () async {
              final userId = ref.read(currentUserIdProvider);
              if (userId != null) {
                try {
                  final repository = ref.read(notificationRepositoryProvider);
                  await repository.markAllAsRead(userId);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تعليم جميع الإشعارات كمقروءة'),
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
            },
          ),
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث', // Refresh
            onPressed: () {
              ref.invalidate(userNotificationsStreamProvider);
              ref.invalidate(unreadNotificationsStreamProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'إجمالي الإشعارات', // Total Notifications
                    value: ref.watch(totalNotificationCountProvider).toString(),
                    icon: Icons.notifications,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'غير المقروءة', // Unread
                    value:
                        ref.watch(unreadNotificationCountProvider).toString(),
                    icon: Icons.mark_email_unread,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'طلبات الاسترداد', // Redemptions
                    value: ref
                        .watch(redemptionNotificationsCountProvider)
                        .toString(),
                    icon: Icons.redeem,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                // Apply filter
                var filteredNotifications = notifications;

                if (_filterType != null) {
                  filteredNotifications = filteredNotifications
                      .where((notification) => notification.type == _filterType)
                      .toList();
                }

                if (filteredNotifications.isEmpty) {
                  return EmptyView(
                    message: _showUnreadOnly
                        ? 'لا توجد إشعارات غير مقروءة' // No unread notifications
                        : 'لا توجد إشعارات', // No notifications
                    icon: Icons.notifications_none,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = filteredNotifications[index];
                    return _NotificationCard(notification: notification);
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => ErrorView(
                error: error.toString(),
                onRetry: () {
                  ref.invalidate(userNotificationsStreamProvider);
                  ref.invalidate(unreadNotificationsStreamProvider);
                },
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

/// Notification card widget
class _NotificationCard extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.redemption:
        return Icons.redeem;
      case NotificationType.lowStock:
        return Icons.inventory_2;
      case NotificationType.newOrder:
        return Icons.shopping_cart;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.custom:
        return Icons.notifications;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.redemption:
        return Colors.purple;
      case NotificationType.lowStock:
        return Colors.orange;
      case NotificationType.newOrder:
        return Colors.green;
      case NotificationType.system:
        return Colors.blue;
      case NotificationType.custom:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = _getColorForType(notification.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? null : color.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(
            _getIconForType(notification.type),
            color: color,
          ),
        ),
        title: Text(
          notification.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.type.displayName,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeago.format(notification.createdAt, locale: 'ar'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            final repository = ref.read(notificationRepositoryProvider);

            switch (value) {
              case 'mark_read':
                if (!notification.isRead) {
                  try {
                    await repository.markAsRead(notification.id);
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
                break;
              case 'delete':
                try {
                  await repository.deleteNotification(notification.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف الإشعار'),
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
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('تعليم كمقروء'), // Mark as read
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
        onTap: () async {
          // Mark as read when tapped
          if (!notification.isRead) {
            try {
              final repository = ref.read(notificationRepositoryProvider);
              await repository.markAsRead(notification.id);
            } catch (e) {
              // Silently fail
            }
          }

          // TODO: Navigate to related screen based on notification type and relatedId
          // For example:
          // if (notification.type == NotificationType.redemption && notification.relatedId != null) {
          //   context.push('/redemptions/${notification.relatedId}');
          // }
        },
      ),
    );
  }
}
