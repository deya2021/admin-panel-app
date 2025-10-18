import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/value_objects/user_role.dart';
import '../data/auth_repository.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Provider for current user (stream)
final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider for current user role (stream)
final currentUserRoleProvider = StreamProvider<UserRole?>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);

  if (user == null) {
    yield null;
    return;
  }

  // Get ID token result to access custom claims
  final idTokenResult = await user.getIdTokenResult();
  final role = idTokenResult.claims?['role'] as String?;

  if (role != null) {
    yield UserRole.fromString(role);
  } else {
    // If no role is set, default to user
    yield UserRole.user;
  }
});

/// Provider for authentication state (boolean)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user != null;
});

/// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.uid;
});

/// Provider for current user email
final currentUserEmailProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  return user?.email;
});

/// Provider for checking if user is admin
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider).value;
  return role?.isAdmin ?? false;
});

/// Provider for checking if user is manager or above
final isManagerOrAboveProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider).value;
  return role?.isManagerOrAbove ?? false;
});

/// Provider for Firebase Auth state changes (raw stream)
/// This is an alternative to currentUserProvider for direct auth state access
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
