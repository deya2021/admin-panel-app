import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/stat_card_widget.dart';
import '../models/order_model.dart';

/// Dashboard screen showing admin panel overview
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(recentOrdersProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentOrdersProvider);
        },
        child: _DashboardContent(),
      ),
    );
  }
}

/// Separate widget to handle loading states properly
class _DashboardContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final ordersAsync = ref.watch(recentOrdersProvider);

    // Show loading for both stats and orders initially
    if (statsAsync.isLoading && ordersAsync.isLoading) {
      return const _DashboardLoading();
    }

    // Show error if stats failed to load
    if (statsAsync.hasError) {
      return ErrorView(
        error: statsAsync.error.toString(),
        onRetry: () => ref.invalidate(dashboardStatsProvider),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards - مع معالجة أفضل للحالات
          _buildStatsSection(statsAsync, ref),
          
          const SizedBox(height: 24),

          // Orders Chart - مع معالجة أفضل للحالات
          _buildOrdersSection(ordersAsync, theme, ref),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AsyncValue statsAsync, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات',
          style: Theme.of(ref.context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        statsAsync.when(
          data: (stats) => GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
            padding: const EdgeInsets.all(4),
            children: [
              StatCard(
                title: 'إجمالي المستخدمين',
                value: stats.totalUsers.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              StatCard(
                title: 'إجمالي المنتجات',
                value: stats.totalProducts.toString(),
                icon: Icons.inventory_2,
                color: Colors.green,
              ),
              StatCard(
                title: 'منتجات قليلة المخزون',
                value: stats.lowStockProducts.toString(),
                icon: Icons.warning,
                color: Colors.orange,
              ),
              StatCard(
                title: 'طلبات استرداد معلقة',
                value: stats.pendingRedemptions.toString(),
                icon: Icons.pending_actions,
                color: Colors.red,
              ),
            ],
          ),
          loading: () => const _StatsLoadingGrid(),
          error: (error, stack) => ErrorView(
            error: 'خطأ في تحميل الإحصائيات: $error',
            onRetry: () => ref.invalidate(dashboardStatsProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersSection(AsyncValue ordersAsync, ThemeData theme, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الطلبات خلال 7 أيام',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ordersAsync.when(
          data: (orders) => _buildOrdersChart(ref.context, orders),
          loading: () => const _ChartLoading(),
          error: (error, stack) => ErrorView(
            error: 'خطأ في تحميل الطلبات: $error',
            onRetry: () => ref.invalidate(recentOrdersProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersChart(BuildContext context, List<OrderModel> orders) {
    // ... (ابقى نفس محتوى الدالة الأصلي)
    if (orders.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('لا توجد طلبات في آخر 7 أيام'),
        ),
      );
    }

    // Group orders by date with safe conversion
    final Map<DateTime, double> dailyTotals = {};
    for (var order in orders) {
      try {
        DateTime orderDate;
        if (order.createdAt is Timestamp) {
          orderDate = (order.createdAt as Timestamp).toDate();
        } else if (order.createdAt is DateTime) {
          orderDate = order.createdAt;
        } else {
          orderDate = DateTime.now();
        }

        final date = DateTime(orderDate.year, orderDate.month, orderDate.day);
        double orderTotal;
        if (order.total is double) {
          orderTotal = order.total;
        } else if (order.total is int) {
          orderTotal = (order.total as int).toDouble();
        } else {
          orderTotal = 0.0;
        }

        dailyTotals[date] = (dailyTotals[date] ?? 0) + orderTotal;
      } catch (e) {
        print('⚠️ خطأ في معالجة طلب: $e');
        continue;
      }
    }

    // Create data points for last 7 days
    final now = DateTime.now();
    final List<FlSpot> spots = [];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final total = dailyTotals[date] ?? 0;
      spots.add(FlSpot(6 - i.toDouble(), total));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.now().subtract(
                        Duration(days: 6 - value.toInt()),
                      );
                      return Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
              minY: 0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading state for dashboard
class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _StatsLoadingGrid(),
          const SizedBox(height: 24),
          const _ChartLoading(),
        ],
      ),
    );
  }
}

/// Loading state for stats grid
class _StatsLoadingGrid extends StatelessWidget {
  const _StatsLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(4),
      children: List.generate(4, (index) => _buildStatCardLoading()),
    );
  }

  Widget _buildStatCardLoading() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.abc, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 12,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading state for chart
class _ChartLoading extends StatelessWidget {
  const _ChartLoading();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('جاري تحميل بيانات الطلبات...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}