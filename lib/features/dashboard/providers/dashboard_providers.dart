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
      totalUsers: (data['usersCount'] as num?)?.toInt() ?? 15,
      totalProducts: (data['productsCount'] as num?)?.toInt() ?? 28,
      lowStockProducts: (data['lowStockCount'] as num?)?.toInt() ?? 3,
      pendingRedemptions: (data['pendingOrdersCount'] as num?)?.toInt() ?? 2,
    );
  }).handleError((error, stackTrace) {
    print('🔥 Firestore Error: $error');
    print('🔄 Falling back to mock data');
    return Stream.value(_getMockStats());
  });
});

final weeklyOrdersProvider = StreamProvider<List<int>>((ref) {
  return FirebaseFirestore.instance
      .collection('stats')
      .doc('main')
      .snapshots()
      .map((doc) {
        final data = doc.data();
        final list = (data?['weeklyOrders'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ?? List<int>.filled(7, 0);
        return list;
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
