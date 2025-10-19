import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPoints {
  final int total;
  final int redeemed;
  int get remaining => total - redeemed;

  const UserPoints({required this.total, required this.redeemed});

  factory UserPoints.fromMap(Map<String, dynamic>? data) {
    final t = (data?['totalPoints'] ?? 0) as num;
    final r = (data?['redeemedPoints'] ?? 0) as num;
    return UserPoints(total: t.toInt(), redeemed: r.toInt());
  }
}

final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

final userDocRefProvider =
    Provider<DocumentReference<Map<String, dynamic>>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return FirebaseFirestore.instance.collection('users').doc(user.uid);
});

final userPointsStreamProvider = StreamProvider<UserPoints?>((ref) {
  final docRef = ref.watch(userDocRefProvider);
  if (docRef == null) return const Stream.empty();
  return docRef.snapshots().map((snap) => UserPoints.fromMap(snap.data()));
});
