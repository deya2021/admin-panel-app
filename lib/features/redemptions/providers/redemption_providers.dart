import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/redemption_repository.dart';
import '../models/redemption_model.dart';

/// Provider for RedemptionRepository
final redemptionRepositoryProvider = Provider<RedemptionRepository>((ref) {
  return RedemptionRepository();
});

/// Provider for all redemptions stream
final redemptionsStreamProvider = StreamProvider<List<RedemptionModel>>((ref) {
  final repository = ref.watch(redemptionRepositoryProvider);
  return repository.getRedemptionsStream();
});

/// Provider for pending redemptions stream
final pendingRedemptionsStreamProvider = StreamProvider<List<RedemptionModel>>((ref) {
  final repository = ref.watch(redemptionRepositoryProvider);
  return repository.getPendingRedemptionsStream();
});

/// Provider for pending redemption count
final pendingRedemptionCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(redemptionRepositoryProvider);
  return repository.getPendingRedemptionCount();
});

