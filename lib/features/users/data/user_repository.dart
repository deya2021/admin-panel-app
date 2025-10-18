import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/value_objects/user_role.dart';
import '../models/user_model.dart';

/// Repository for user management operations
class UserRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'users';

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get stream of all users
  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of users by role
  Stream<List<UserModel>> getUsersByRoleStream(UserRole role) {
    return _firestore
        .collection(_collection)
        .where('role', isEqualTo: role.value)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of active users
  Stream<List<UserModel>> getActiveUsersStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get stream of user by ID
  Stream<UserModel?> getUserByIdStream(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  /// Create or update user
  Future<void> setUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw Exception('Failed to set user: $e');
    }
  }

  /// Update user role
  /// Note: This only updates Firestore. You must also update Firebase Auth custom claims
  /// using a Cloud Function or Admin SDK
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'role': role.value,
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Update user active status
  Future<void> updateUserActiveStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Update user last login timestamp
  Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      
      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await _firestore.collection(_collection).doc(userId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Delete user (soft delete by setting isActive to false)
  Future<void> deactivateUser(String userId) async {
    try {
      await updateUserActiveStatus(userId, false);
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  /// Permanently delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get user count
  Future<int> getUserCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get user count: $e');
    }
  }

  /// Get active user count
  Future<int> getActiveUserCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get active user count: $e');
    }
  }

  /// Search users by email or display name
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation. For production, consider using Algolia or similar
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('email', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}

