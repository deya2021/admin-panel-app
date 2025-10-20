import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/redemption_model.dart';

/// Repository for redemption management operations
class RedemptionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final String _collection = 'redemptions';

  RedemptionRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

  /// Get stream of all redemptions ordered by createdAt desc
  Stream<List<RedemptionModel>> getRedemptionsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RedemptionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of pending redemptions
  Stream<List<RedemptionModel>> getPendingRedemptionsStream() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RedemptionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get redemption by ID
  Future<RedemptionModel?> getRedemptionById(String redemptionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(redemptionId).get();
      if (doc.exists && doc.data() != null) {
        return RedemptionModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get redemption: $e');
    }
  }

  /// Approve redemption using Cloud Function
  Future<void> approveRedemption(String redemptionId, String handledBy) async {
    try {
      final callable = _functions.httpsCallable('processRedemption');
      final result = await callable.call<Map<String, dynamic>>({
        'redemptionId': redemptionId,
        'action': 'approve',
      });
      
      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? 'Failed to approve redemption');
      }
    } catch (e) {
      throw Exception('Failed to approve redemption: $e');
    }
  }

  /// Reject redemption using Cloud Function
  Future<void> rejectRedemption(String redemptionId, String handledBy) async {
    try {
      final callable = _functions.httpsCallable('processRedemption');
      final result = await callable.call<Map<String, dynamic>>({
        'redemptionId': redemptionId,
        'action': 'reject',
      });
      
      if (result.data['success'] != true) {
        throw Exception(result.data['message'] ?? 'Failed to reject redemption');
      }
    } catch (e) {
      throw Exception('Failed to reject redemption: $e');
    }
  }

  /// Get pending redemption count
  Future<int> getPendingRedemptionCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get pending redemption count: $e');
    }
  }

  /// Get redemption count by status
  Future<int> getRedemptionCountByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get redemption count: $e');
    }
  }
}

