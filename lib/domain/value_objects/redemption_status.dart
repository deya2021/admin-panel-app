import 'package:flutter/material.dart';

/// Redemption status enum
enum RedemptionStatus {
  pending('pending', 'معلق', Colors.orange),
  approved('approved', 'موافق عليه', Colors.blue),
  rejected('rejected', 'مرفوض', Colors.red),
  completed('completed', 'مكتمل', Colors.green);

  final String value;
  final String displayName;
  final Color color;

  const RedemptionStatus(this.value, this.displayName, this.color);

  /// Check if status is pending
  bool get isPending => this == RedemptionStatus.pending;

  /// Check if status is approved
  bool get isApproved => this == RedemptionStatus.approved;

  /// Check if status is rejected
  bool get isRejected => this == RedemptionStatus.rejected;

  /// Check if status is completed
  bool get isCompleted => this == RedemptionStatus.completed;

  /// Check if status can be updated
  bool get canBeUpdated => isPending || isApproved;

  /// Parse status from string
  static RedemptionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return RedemptionStatus.pending;
      case 'approved':
        return RedemptionStatus.approved;
      case 'rejected':
        return RedemptionStatus.rejected;
      case 'completed':
        return RedemptionStatus.completed;
      default:
        return RedemptionStatus.pending;
    }
  }

  /// Convert to string
  @override
  String toString() => value;
}

