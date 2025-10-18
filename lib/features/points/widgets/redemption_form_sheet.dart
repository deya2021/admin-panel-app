import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/points_providers.dart';
import '../models/points_ledger_entry.dart';

/// Redemption form bottom sheet
class RedemptionFormSheet extends ConsumerStatefulWidget {
  const RedemptionFormSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<RedemptionFormSheet> createState() => _RedemptionFormSheetState();
}

class _RedemptionFormSheetState extends ConsumerState<RedemptionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pointsController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pointsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRedemption() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final points = int.parse(_pointsController.text);
      final description = _descriptionController.text.trim();

      final submitFn = ref.read(submitRedemptionProvider);
      await submitFn(points, description);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلب الاسترداد بنجاح'), // Redemption request submitted successfully
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'), // Error
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pointsAsync = ref.watch(userTotalPointsProvider);
    final ledgerAsync = ref.watch(userPointsLedgerProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'النقاط والاسترداد', // Points & Redemption
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total points display
                      pointsAsync.when(
                        data: (points) => _buildTotalPointsCard(context, points),
                        loading: () => const Center(child: LoadingIndicator()),
                        error: (_, __) => _buildTotalPointsCard(context, 0),
                      ),

                      const SizedBox(height: 24),

                      // Redemption form
                      Text(
                        'طلب استرداد', // Redemption Request
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _pointsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'عدد النقاط', // Number of points
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.stars),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال عدد النقاط'; // Please enter number of points
                                }
                                final points = int.tryParse(value);
                                if (points == null || points <= 0) {
                                  return 'الرجاء إدخال رقم صحيح'; // Please enter a valid number
                                }
                                final totalPoints = pointsAsync.value ?? 0;
                                if (points > totalPoints) {
                                  return 'النقاط المطلوبة أكبر من الرصيد المتاح'; // Requested points exceed available balance
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'الوصف (اختياري)', // Description (optional)
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitRedemption,
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('إرسال الطلب'), // Submit Request
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Points ledger
                      Text(
                        'سجل النقاط', // Points Ledger
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ledgerAsync.when(
                        data: (entries) => entries.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text('لا توجد حركات'), // No transactions
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: entries.length,
                                itemBuilder: (context, index) {
                                  return _buildLedgerEntry(context, entries[index]);
                                },
                              ),
                        loading: () => const Center(child: LoadingIndicator()),
                        error: (error, _) => Center(
                          child: Text('خطأ: ${error.toString()}'), // Error
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalPointsCard(BuildContext context, int points) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.stars, size: 48, color: Colors.amber),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي النقاط', // Total Points
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  points.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerEntry(BuildContext context, PointsLedgerEntry entry) {
    final theme = Theme.of(context);
    Color color;
    switch (entry.typeColor) {
      case 'green':
        color = Colors.green;
        break;
      case 'red':
        color = Colors.red;
        break;
      case 'orange':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(
            entry.type == 'earned' ? Icons.add : Icons.remove,
            color: color,
          ),
        ),
        title: Text(entry.typeDisplay),
        subtitle: entry.description != null
            ? Text(entry.description!)
            : Text('${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}'),
        trailing: Text(
          '${entry.points > 0 ? '+' : ''}${entry.points}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

