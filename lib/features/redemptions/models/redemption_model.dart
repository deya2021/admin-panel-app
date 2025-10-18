import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Redemption model for points redemption requests
class RedemptionModel {
  final String id;
  final String userId;
  final int points;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final String? handledBy;
  final DateTime? handledAt;

  RedemptionModel({
    required this.id,
    required this.userId,
    required this.points,
    required this.status,
    required this.createdAt,
    this.handledBy,
    this.handledAt,
  });

  /// Create RedemptionModel from Firestore document
  factory RedemptionModel.fromMap(Map<String, dynamic> map, String id) {
    return RedemptionModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      points: map['points'] as int? ?? 0,
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      handledBy: map['handledBy'] as String?,
      handledAt: (map['handledAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert RedemptionModel to Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'points': points,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (handledBy != null) 'handledBy': handledBy,
      if (handledAt != null) 'handledAt': Timestamp.fromDate(handledAt!),
    };
  }

  /// Check if redemption is pending
  bool get isPending => status == 'pending';

  /// Check if redemption is approved
  bool get isApproved => status == 'approved';

  /// Check if redemption is rejected
  bool get isRejected => status == 'rejected';

  /// Get status color
  Color get statusColor {
    switch (status) {
      case 'approved':
        return const Color(0xFF4CAF50); // Green
      case 'rejected':
        return const Color(0xFFF44336); // Red
      case 'pending':
      default:
        return const Color(0xFFFF9800); // Orange
    }
  }

  /// Get status label in Arabic
  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
      default:
        return 'معلق';
    }
  }

  /// Copy with method
  RedemptionModel copyWith({
    String? id,
    String? userId,
    int? points,
    String? status,
    DateTime? createdAt,
    String? handledBy,
    DateTime? handledAt,
  }) {
    return RedemptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      handledBy: handledBy ?? this.handledBy,
      handledAt: handledAt ?? this.handledAt,
    );
  }
}

