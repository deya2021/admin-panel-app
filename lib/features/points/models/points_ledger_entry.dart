import 'package:cloud_firestore/cloud_firestore.dart';

/// Points ledger entry model
class PointsLedgerEntry {
  final String id;
  final String userId;
  final int points;
  final String type; // 'earned', 'redeemed', 'adjusted'
  final String? orderId;
  final String? redemptionId;
  final String? description;
  final DateTime createdAt;

  PointsLedgerEntry({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    this.orderId,
    this.redemptionId,
    this.description,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory PointsLedgerEntry.fromMap(Map<String, dynamic> data, String id) {
    // Safe date parsing
    DateTime createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is DateTime) {
      createdAt = data['createdAt'] as DateTime;
    } else {
      createdAt = DateTime.now();
    }

    return PointsLedgerEntry(
      id: id,
      userId: data['userId'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      type: data['type'] as String? ?? 'adjusted',
      orderId: data['orderId'] as String?,
      redemptionId: data['redemptionId'] as String?,
      description: data['description'] as String?,
      createdAt: createdAt,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'points': points,
      'type': type,
      if (orderId != null) 'orderId': orderId,
      if (redemptionId != null) 'redemptionId': redemptionId,
      if (description != null) 'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Get display text for type
  String get typeDisplay {
    switch (type) {
      case 'earned':
        return 'نقاط مكتسبة'; // Points earned
      case 'redeemed':
        return 'نقاط مستردة'; // Points redeemed
      case 'adjusted':
        return 'تعديل'; // Adjustment
      default:
        return type;
    }
  }

  /// Get color for type
  String get typeColor {
    switch (type) {
      case 'earned':
        return 'green';
      case 'redeemed':
        return 'red';
      case 'adjusted':
        return 'orange';
      default:
        return 'grey';
    }
  }
}

