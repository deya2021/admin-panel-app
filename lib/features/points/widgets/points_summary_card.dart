import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/points_providers.dart';
import 'redemption_form_sheet.dart';

/// Points summary card widget for dashboard
class PointsSummaryCard extends ConsumerWidget {
  const PointsSummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pointsAsync = ref.watch(userTotalPointsProvider);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Show redemption form
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const RedemptionFormSheet(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.stars,
                size: 40,
                color: Colors.amber,
              ),
              const SizedBox(height: 12),
              pointsAsync.when(
                data: (points) => Text(
                  points.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                loading: () => const SizedBox(
                  height: 32,
                  child: LoadingIndicator(),
                ),
                error: (_, __) => Text(
                  '0',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'نقاطي', // My Points
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

