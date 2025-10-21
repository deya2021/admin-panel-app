import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/error_view.dart';
import '../../points/widgets/points_summary_card.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/stat_card_widget.dart';

/// Dashboard screen showing admin panel overview
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(weeklyOrdersProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(weeklyOrdersProvider);
        },
        child: const _DashboardContent(),
      ),
    );
  }
}

/// Separate widget to handle loading states properly
class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final weeklyOrdersAsync = ref.watch(weeklyOrdersProvider);

    // Show loading for both stats and weekly orders initially
    if (statsAsync.isLoading && weeklyOrdersAsync.isLoading) {
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
          // Stats Cards section
          _buildStatsSection(statsAsync, ref),

          // Points summary card
          const SizedBox(height: 16),
          const PointsSummaryCard(),
          const SizedBox(height: 24),

          // Weekly Orders Chart
          _buildWeeklyOrdersSection(weeklyOrdersAsync, ref),
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

  Widget _buildWeeklyOrdersSection(
      AsyncValue<List<int>> weeklyOrdersAsync, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الطلبات خلال 7 أيام',
          style: Theme.of(ref.context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        weeklyOrdersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('تعذر تحميل البيانات'),
            ),
          ),
          data: (list) => _WeeklyOrdersMiniChart(values: list),
        ),
      ],
    );
  }
}

class _WeeklyOrdersMiniChart extends StatelessWidget {
  final List<int> values;
  const _WeeklyOrdersMiniChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final maxV =
        (values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b))
            .clamp(1, 999999);
    const labelHeight = 14.0;
    const gap = 6.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16).copyWith(bottom: 6),
        child: SizedBox(
          height: 120,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barArea = constraints.maxHeight - labelHeight - gap;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final h = (values[i] / maxV) * barArea;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: h,
                            width: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: gap),
                          Text(
                            ['س', 'أ', 'ث', 'أر', 'خ', 'ج', 'س'][i],
                            style: const TextStyle(fontSize: 10, height: 1.0),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
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
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _StatsLoadingGrid(),
          SizedBox(height: 24),
          _ChartLoading(),
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
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تحميل بيانات الطلبات...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
