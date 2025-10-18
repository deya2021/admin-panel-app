import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// واجهة المصادقة
abstract class AuthRepository {
  /// تسجيل الدخول بالبريد
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// اسم بديل للحفاظ على التوافق
  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// ستريم تغيّر حالة المستخدم (User? من Firebase)
  Stream<User?> userChanges();

  /// تجديد التوكن (اختياري)
  Future<String?> refreshToken();
}

/// تنفيذ Firebase
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _fa;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _fa = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _fa.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> signOut() => _fa.signOut();

  @override
  Stream<User?> userChanges() => _fa.authStateChanges();

  @override
  Future<String?> refreshToken() async {
    final user = _fa.currentUser;
    if (user == null) return null;
    return user.getIdToken(true); // force refresh
  }
}

/// مزوّد الـ Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});
