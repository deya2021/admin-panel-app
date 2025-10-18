import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/dashboard_stats.dart';

/// Repository for dashboard data
class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get dashboard statistics
  Future<DashboardStats> getDashboardStats() async {
    try {
      // Get total users
      final usersSnapshot = await _firestore.collection('users').count().get();
      final totalUsers = usersSnapshot.count ?? 0;

      // Get total products
      final productsSnapshot = await _firestore.collection('products').count().get();
      final totalProducts = productsSnapshot.count ?? 0;

      // Get low stock products (stock <= 5)
      final lowStockSnapshot = await _firestore
          .collection('products')
          .where('stock', isLessThanOrEqualTo: 5)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      final lowStockProducts = lowStockSnapshot.count ?? 0;

      // Get pending redemptions
      final pendingRedemptionsSnapshot = await _firestore
          .collection('redemptions')
          .where('status', isEqualTo: 'pending')
          .count()
          .get();
      final pendingRedemptions = pendingRedemptionsSnapshot.count ?? 0;

      return DashboardStats(
        totalUsers: totalUsers,
        totalProducts: totalProducts,
        lowStockProducts: lowStockProducts,
        pendingRedemptions: pendingRedemptions,
      );
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  /// Get orders for the last N days
  Future<List<OrderModel>> getRecentOrders(int days) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('orders')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent orders: $e');
    }
  }

  /// Stream of dashboard stats (for real-time updates)
  Stream<DashboardStats> getDashboardStatsStream() {
    // Note: Firestore doesn't support streaming count queries directly
    // This is a workaround that polls every 30 seconds
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => getDashboardStats())
        .handleError((error) {
      throw Exception('Failed to stream dashboard stats: $error');
    });
  }
}

