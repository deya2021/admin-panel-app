import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/empty_view.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/redemption_providers.dart';
import '../models/redemption_model.dart';
import '../../users/providers/user_providers.dart';

/// Redemption list screen for managing redemption requests
class RedemptionListScreen extends ConsumerStatefulWidget {
  const RedemptionListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RedemptionListScreen> createState() => _RedemptionListScreenState();
}

class _RedemptionListScreenState extends ConsumerState<RedemptionListScreen> {
  String _filterStatus = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    // Initialize Arabic locale for timeago
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final redemptionsAsync = ref.watch(redemptionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات الاسترداد'), // Redemption Requests
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'تصفية', // Filter
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('الكل'), // All
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('معلقة'), // Pending
              ),
              const PopupMenuItem(
                value: 'approved',
                child: Text('مقبولة'), // Approved
              ),
              const PopupMenuItem(
                value: 'rejected',
                child: Text('مرفوضة'), // Rejected
              ),
            ],
          ),
        ],
      ),
      body: redemptionsAsync.when(
        data: (redemptions) {
          // Filter redemptions by status
          final filteredRedemptions = _filterStatus == 'all'
              ? redemptions
              : redemptions.where((r) => r.status == _filterStatus).toList();

          if (filteredRedemptions.isEmpty) {
            return EmptyView(
              message: _filterStatus == 'all'
                  ? 'لا توجد طلبات استرداد' // No redemption requests
                  : 'لا توجد طلبات $_filterStatus', // No {status} requests
              icon: Icons.pending_actions_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(redemptionsStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRedemptions.length,
              itemBuilder: (context, index) {
                final redemption = filteredRedemptions[index];
                return _buildRedemptionCard(context, redemption);
              },
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorView(
          error: error.toString(),
          onRetry: () => ref.invalidate(redemptionsStreamProvider),
        ),
      ),
    );
  }

  /// Build redemption card
  Widget _buildRedemptionCard(BuildContext context, RedemptionModel redemption) {
    final theme = Theme.of(context);
    final timeAgo = timeago.format(redemption.createdAt, locale: 'ar');
    
    // Watch user data to get current points balance
    final userAsync = ref.watch(userByIdStreamProvider(redemption.userId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: redemption.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    redemption.statusLabel,
                    style: TextStyle(
                      color: redemption.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                // Time Ago


                Text(
                  timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // User ID
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'المستخدم: ${redemption.userId}', // User
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Points
            Row(
              children: [
                Icon(Icons.stars, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'النقاط المطلوبة: ${redemption.points}', // Requested Points
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // User's Current Points Balance
            const SizedBox(height: 8),
            userAsync.when(
              data: (user) {
                if (user == null) return const SizedBox.shrink();
                final currentPoints = user.totalPoints;
                final hasEnoughPoints = currentPoints >= redemption.points;
                return Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: hasEnoughPoints ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'رصيد المستخدم: $currentPoints نقطة', // User balance
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasEnoughPoints ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
              loading: () => Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'جاري تحميل الرصيد...', // Loading balance
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Handled Info (if approved or rejected)
            if (redemption.handledBy != null && redemption.handledAt != null) ...[
              const SizedBox(height: 8),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تم المعالجة بواسطة: ${redemption.handledBy}', // Handled by
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    timeago.format(redemption.handledAt!, locale: 'ar'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],

            // Action Buttons (only for pending)
            if (redemption.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleReject(context, redemption),
                      icon: const Icon(Icons.close),
                      label: const Text('رفض'), // Reject
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleApprove(context, redemption),
                      icon: const Icon(Icons.check),
                      label: const Text('قبول'), // Approve
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handle approve redemption
  Future<void> _handleApprove(BuildContext context, RedemptionModel redemption) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد القبول'), // Confirm Approval
        content: Text('هل أنت متأكد من قبول طلب استرداد ${redemption.points} نقطة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'), // Cancel
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('قبول'), // Approve
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final currentUserId = ref.read(currentUserIdProvider);
        if (currentUserId == null) {
          throw Exception('User not authenticated');
        }

        await ref
            .read(redemptionRepositoryProvider)
            .approveRedemption(redemption.id, currentUserId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم قبول الطلب بنجاح')), // Approved successfully
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل قبول الطلب: $e')), // Failed to approve
          );
        }
      }
    }
  }

  /// Handle reject redemption
  Future<void> _handleReject(BuildContext context, RedemptionModel redemption) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الرفض'), // Confirm Rejection
        content: Text('هل أنت متأكد من رفض طلب استرداد ${redemption.points} نقطة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'), // Cancel
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('رفض'), // Reject
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final currentUserId = ref.read(currentUserIdProvider);
        if (currentUserId == null) {
          throw Exception('User not authenticated');
        }

        await ref
            .read(redemptionRepositoryProvider)
            .rejectRedemption(redemption.id, currentUserId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض الطلب بنجاح')), // Rejected successfully
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل رفض الطلب: $e')), // Failed to reject
          );
        }
      }
    }
  }
}

