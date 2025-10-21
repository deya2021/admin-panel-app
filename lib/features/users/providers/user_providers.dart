import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';
import '../models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final usersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersStream();
});

final userByIdStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserByIdStream(userId);
});

final userCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserCount();
});