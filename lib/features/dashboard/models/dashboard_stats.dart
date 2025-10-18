class DashboardStats {
  final int totalUsers;
  final int totalProducts;
  final int lowStockProducts;
  final int pendingRedemptions;

  DashboardStats({
    required this.totalUsers,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.pendingRedemptions,
  });

  // constructor بسيط بدون fromMap إذا كان يسبب مشاكل
  factory DashboardStats.empty() {
    return DashboardStats(
      totalUsers: 0,
      totalProducts: 0,
      lowStockProducts: 0,
      pendingRedemptions: 0,
    );
  }
}
