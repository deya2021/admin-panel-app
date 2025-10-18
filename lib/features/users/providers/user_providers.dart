import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/value_objects/user_role.dart';
import '../data/user_repository.dart';
import '../models/user_model.dart';

/// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Provider for all users stream
final usersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersStream();
});

/// Provider for active users stream
final activeUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getActiveUsersStream();
});

/// Provider for users by role stream
final usersByRoleStreamProvider = StreamProvider.family<List<UserModel>, UserRole>((ref, role) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersByRoleStream(role);
});

/// Provider for admin users stream
final adminUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersByRoleStream(UserRole.admin);
});

/// Provider for manager users stream
final managerUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersByRoleStream(UserRole.manager);
});

/// Provider for regular users stream
final regularUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersByRoleStream(UserRole.user);
});

/// Provider for user by ID stream
final userByIdStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserByIdStream(userId);
});

/// Provider for user count
final userCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserCount();
});

/// Provider for active user count
final activeUserCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getActiveUserCount();
});

/// Provider for total users count from stream
final totalUsersCountProvider = Provider<int>((ref) {
  final usersAsync = ref.watch(usersStreamProvider);
  return usersAsync.when(
    data: (users) => users.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for total active users count from stream
final totalActiveUsersCountProvider = Provider<int>((ref) {
  final usersAsync = ref.watch(activeUsersStreamProvider);
  return usersAsync.when(
    data: (users) => users.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for admin count
final adminCountProvider = Provider<int>((ref) {
  final adminsAsync = ref.watch(adminUsersStreamProvider);
  return adminsAsync.when(
    data: (admins) => admins.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for manager count
final managerCountProvider = Provider<int>((ref) {
  final managersAsync = ref.watch(managerUsersStreamProvider);
  return managersAsync.when(
    data: (managers) => managers.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

