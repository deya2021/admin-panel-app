import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_stats.dart';
import '../models/order_model.dart';

/// Provider للاتصال بـ Firestore
final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// إصدار حقيقي مع fallback للبيانات الوهمية
final dashboardStatsProvider = StreamProvider<DashboardStats>((ref) {
  final firestore = ref.watch(_firestoreProvider);

  return firestore.collection('stats').doc('main').snapshots().map((snapshot) {
    print('📊 Firestore Data: ${snapshot.data()}');

    if (!snapshot.exists) {
      print('⚠️ No stats document found, using mock data');
      return _getMockStats();
    }

    final data = snapshot.data()!;
    return DashboardStats(
      totalUsers: (data['totalUsers'] as num?)?.toInt() ?? 15,
      totalProducts: (data['totalProducts'] as num?)?.toInt() ?? 28,
      lowStockProducts: (data['lowStockProducts'] as num?)?.toInt() ?? 3,
      pendingRedemptions: (data['pendingRedemptions'] as num?)?.toInt() ?? 2,
    );
  }).handleError((error, stackTrace) {
    print('🔥 Firestore Error: $error');
    print('🔄 Falling back to mock data');
    return Stream.value(_getMockStats());
  });
});

/// إصدار حقيقي للطلبات مع fallback
final recentOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final firestore = ref.watch(_firestoreProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  return firestore
      .collection('orders')
      .where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    print('📦 Orders found: ${snapshot.docs.length}');

    if (snapshot.docs.isEmpty) {
      print('⚠️ No orders found, using mock data');
      return _getMockOrders();
    }

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return OrderModel(
        id: doc.id,
        userId: data['userId'] as String? ?? 'unknown',
        total: (data['total'] as num?)?.toDouble() ?? 0.0,
        status: data['status'] as String? ?? 'pending',
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }).handleError((error, stackTrace) {
    print('🔥 Orders Error: $error');
    print('🔄 Falling back to mock orders');
    return Stream.value(_getMockOrders());
  });
});

// بيانات وهمية للطوارئ
DashboardStats _getMockStats() {
  return DashboardStats(
    totalUsers: 15,
    totalProducts: 28,
    lowStockProducts: 3,
    pendingRedemptions: 2,
  );
}

List<OrderModel> _getMockOrders() {
  final now = DateTime.now();
  return [
    OrderModel(
      id: 'mock1',
      userId: 'user1',
      total: 150.0,
      status: 'completed',
      createdAt: now.subtract(Duration(days: 1)),
    ),
    OrderModel(
      id: 'mock2',
      userId: 'user2',
      total: 200.0,
      status: 'completed',
      createdAt: now.subtract(Duration(days: 2)),
    ),
  ];
}
