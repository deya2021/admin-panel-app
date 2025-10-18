import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification types
enum NotificationType {
  redemption('redemption', 'طلب استرداد'),
  lowStock('low_stock', 'مخزون منخفض'),
  newOrder('new_order', 'طلب جديد'),
  system('system', 'نظام'),
  custom('custom', 'مخصص');

  final String value;
  final String displayName;

  const NotificationType(this.value, this.displayName);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

/// Notification model representing a notification in the system
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? targetUserId; // If null, it's a broadcast
  final String? relatedId; // ID of related entity (redemption, product, etc.)
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetUserId,
    this.relatedId,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: NotificationType.fromString(map['type'] as String? ?? 'system'),
      targetUserId: map['targetUserId'] as String?,
      relatedId: map['relatedId'] as String?,
      data: map['data'] as Map<String, dynamic>?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert NotificationModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.value,
      'targetUserId': targetUserId,
      'relatedId': relatedId,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  /// Create a copy with updated fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? targetUserId,
    String? relatedId,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      targetUserId: targetUserId ?? this.targetUserId,
      relatedId: relatedId ?? this.relatedId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: ${type.value}, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is NotificationModel &&
      other.id == id &&
      other.title == title &&
      other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ type.hashCode;
}

