import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/points_providers.dart';
import 'redemption_form_sheet.dart';

class PointsSummaryCard extends ConsumerWidget {
  final EdgeInsetsGeometry padding;
  const PointsSummaryCard({super.key, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointsAsync = ref.watch(userPointsStreamProvider);

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: padding,
        child: pointsAsync.when(
          data: (p) {
            final total = p?.total ?? 0;
            final redeemed = p?.redeemed ?? 0;
            final remaining =
                (p?.remaining ?? (total - redeemed)).clamp(0, 1 << 31);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loyalty Points',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _metric(context, 'Total', total),
                    _metric(context, 'Redeemed', redeemed),
                    _metric(context, 'Remaining', remaining),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showModalBottomSheet<int>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const RedemptionFormSheet(),
                      );
                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Requested redeem: $result pts')),
                        );
                        // لاحقًا: يمكنك إرسال الطلب إلى Cloud Function/Firestore
                      }
                    },
                    icon: const Icon(Icons.redeem),
                    label: const Text('Redeem'),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 72,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
    );
  }

  Widget _metric(BuildContext context, String label, int value) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.labelMedium),
        const SizedBox(height: 4),
        Text('$value',
            style: t.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
