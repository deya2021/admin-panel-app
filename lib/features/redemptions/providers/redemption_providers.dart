import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/redemption_repository.dart';
import '../models/redemption_model.dart';

final redemptionRepositoryProvider = Provider<RedemptionRepository>((ref) {
  return RedemptionRepository();
});

final redemptionsStreamProvider = StreamProvider<List<RedemptionModel>>((ref) {
  final repository = ref.watch(redemptionRepositoryProvider);
  return repository.getRedemptionsStream();
});

final pendingRedemptionsStreamProvider = StreamProvider<List<RedemptionModel>>((ref) {
  final repository = ref.watch(redemptionRepositoryProvider);
  return repository.getPendingRedemptionsStream();
});

final pendingRedemptionCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(redemptionRepositoryProvider);
  return repository.getPendingRedemptionCount();
});