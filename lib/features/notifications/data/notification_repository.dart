import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

/// Repository for notification management operations
class NotificationRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'notifications';

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get stream of all notifications
  Stream<List<NotificationModel>> getNotificationsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of notifications for a specific user
  Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('targetUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of broadcast notifications (no specific target user)
  Stream<List<NotificationModel>> getBroadcastNotificationsStream() {
    return _firestore
        .collection(_collection)
        .where('targetUserId', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of unread notifications for a user
  Stream<List<NotificationModel>> getUnreadNotificationsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('targetUserId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of notifications by type
  Stream<List<NotificationModel>> getNotificationsByTypeStream(NotificationType type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(notificationId).get();
      if (doc.exists && doc.data() != null) {
        return NotificationModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  /// Create notification
  Future<String> createNotification(NotificationModel notification) async {
    try {
      final docRef = await _firestore.collection(_collection).add(notification.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Create broadcast notification (sent to all admins/managers)
  Future<String> createBroadcastNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '', // Will be set by Firestore
        title: title,
        body: body,
        type: type,
        targetUserId: null, // Broadcast
        relatedId: relatedId,
        data: data,
        createdAt: DateTime.now(),
      );

      return await createNotification(notification);
    } catch (e) {
      throw Exception('Failed to create broadcast notification: $e');
    }
  }

  /// Create user-specific notification
  Future<String> createUserNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: '', // Will be set by Firestore
        title: title,
        body: body,
        type: type,
        targetUserId: userId,
        relatedId: relatedId,
        data: data,
        createdAt: DateTime.now(),
      );

      return await createNotification(notification);
    } catch (e) {
      throw Exception('Failed to create user notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('targetUserId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Delete all notifications for a user
  Future<void> deleteAllUserNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('targetUserId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all user notifications: $e');
    }
  }

  /// Get unread notification count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('targetUserId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Delete old notifications (older than specified days)
  Future<void> deleteOldNotifications({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final batch = _firestore.batch();
      
      final snapshot = await _firestore
          .collection(_collection)
          .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete old notifications: $e');
    }
  }
}

