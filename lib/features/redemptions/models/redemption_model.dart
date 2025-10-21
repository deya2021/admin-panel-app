import 'package:flutter/material.dart';

class RedemptionModel {
  final String id;
  final String userId;
  final int points;
  final double amount;
  final DateTime createdAt;
  final String status;
  final String? handledBy;
  final DateTime? handledAt;

  const RedemptionModel({
    required this.id,
    required this.userId,
    required this.points,
    required this.amount,
    required this.createdAt,
    required this.status,
    this.handledBy,
    this.handledAt,
  });

  factory RedemptionModel.fromMap(Map<String, dynamic> map, String id) {
    return RedemptionModel(
      id: id,
      userId: map['userId'] ?? '',
      points: map['points'] ?? 0,
      amount: (map['amount'] ?? 0.0).toDouble(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      handledBy: map['handledBy'],
      handledAt: map['handledAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'points': points,
      'amount': amount,
      'createdAt': createdAt,
      'status': status,
      'handledBy': handledBy,
      'handledAt': handledAt,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'معلقة';
      case 'approved':
        return 'مقبولة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}