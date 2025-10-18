import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/points_ledger_entry.dart';

/// Provider for Firestore instance
final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider for current user's total points
final userTotalPointsProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(0);
  }

  final firestore = ref.watch(_firestoreProvider);
  return firestore.collection('users').doc(userId).snapshots().map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      return 0;
    }
    final data = snapshot.data()!;
    return (data['totalPoints'] as num?)?.toInt() ?? 0;
  });
});

/// Provider for current user's points ledger (last 50 entries)
final userPointsLedgerProvider = StreamProvider<List<PointsLedgerEntry>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = ref.watch(_firestoreProvider);
  return firestore
      .collection('users')
      .doc(userId)
      .collection('points_ledger')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => PointsLedgerEntry.fromMap(doc.data(), doc.id))
        .toList();
  });
});

/// Provider to submit redemption request
final submitRedemptionProvider = Provider<Future<void> Function(int points, String description)>((ref) {
  return (int points, String description) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final firestore = ref.read(_firestoreProvider);

    // Create redemption request
    await firestore.collection('redemptions').add({
      'userId': userId,
      'points': points,
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  };
});

