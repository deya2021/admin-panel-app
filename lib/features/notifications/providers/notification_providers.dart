import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/notification_repository.dart';
import '../models/notification_model.dart';

/// Provider for NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

/// Provider for all notifications stream
final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotificationsStream();
});

/// Provider for current user's notifications stream
final userNotificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }
  
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUserNotificationsStream(userId);
});

/// Provider for broadcast notifications stream
final broadcastNotificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getBroadcastNotificationsStream();
});

/// Provider for unread notifications stream
final unreadNotificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }
  
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadNotificationsStream(userId);
});

/// Provider for notifications by type stream
final notificationsByTypeStreamProvider = StreamProvider.family<List<NotificationModel>, NotificationType>((ref, type) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotificationsByTypeStream(type);
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final unreadAsync = ref.watch(unreadNotificationsStreamProvider);
  return unreadAsync.when(
    data: (notifications) => notifications.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for total notification count
final totalNotificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(userNotificationsStreamProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for redemption notifications count
final redemptionNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsByTypeStreamProvider(NotificationType.redemption));
  return notificationsAsync.when(
    data: (notifications) => notifications.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for low stock notifications count
final lowStockNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsByTypeStreamProvider(NotificationType.lowStock));
  return notificationsAsync.when(
    data: (notifications) => notifications.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

