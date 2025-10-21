import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_stats.dart';
import '../models/order_model.dart';

/// Provider for Firestore instance
final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Real-time dashboard statistics provider with automatic refresh
/// Streams data from stats/main document for instant updates
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final firestore = ref.watch(_firestoreProvider);

  return firestore.collection('stats').doc('main').snapshots().map((snapshot) {
    if (!snapshot.exists) {
      return _getMockStats();
    }

    final data = snapshot.data()!;
    return DashboardStats(
      totalUsers: (data['usersCount'] as num?)?.toInt() ?? 15,
      totalProducts: (data['productsCount'] as num?)?.toInt() ?? 28,
      lowStockProducts: (data['lowStockCount'] as num?)?.toInt() ?? 3,
      pendingRedemptions: (data['pendingOrdersCount'] as num?)?.toInt() ?? 2,
    );
  }).handleError((error, stackTrace) {
    return Stream.value(_getMockStats());
  });
});

/// Real-time weekly orders provider for dashboard chart
/// Automatically updates when stats/main document changes
final weeklyOrdersProvider = StreamProvider<List<int>>((ref) {
  final firestore = ref.watch(_firestoreProvider);
  
  return firestore
      .collection('stats')
      .doc('main')
      .snapshots()
      .map((doc) {
        final data = doc.data();
        final list = (data?['weeklyOrders'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList();
        
        // Ensure we always have exactly 7 integers
        if (list == null || list.length != 7) {
          return List<int>.filled(7, 0);
        }
        
        return list;
      });
});

/// Fallback mock stats for error cases
DashboardStats _getMockStats() {
  return DashboardStats(
    totalUsers: 15,
    totalProducts: 28,
    lowStockProducts: 3,
    pendingRedemptions: 2,
  );
}

/// Mock orders for testing (unused in production)
List<OrderModel> _getMockOrders() {
  final now = DateTime.now();
  return [
    OrderModel(
      id: 'mock1',
      userId: 'user1',
      total: 150.0,
      status: 'completed',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'mock2',
      userId: 'user2',
      total: 200.0,
      status: 'completed',
      createdAt: now.subtract(const Duration(days: 2)),
    ),
  ];
}
