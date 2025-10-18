import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

/// Repository for category management operations
class CategoryRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'categories';

  CategoryRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get stream of all categories ordered by sortOrder
  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(categoryId).get();
      if (doc.exists && doc.data() != null) {
        return CategoryModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  /// Create category
  Future<String> createCategory(String name, int sortOrder) async {
    try {
      final data = {
        'name': name,
        'sortOrder': sortOrder,
        'createdAt': FieldValue.serverTimestamp(),
      };
      final docRef = await _firestore.collection(_collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  /// Update category
  Future<void> updateCategory(String categoryId, String name, int sortOrder) async {
    try {
      await _firestore.collection(_collection).doc(categoryId).update({
        'name': name,
        'sortOrder': sortOrder,
      });
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_collection).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Get category count
  Future<int> getCategoryCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get category count: $e');
    }
  }

  /// Get next sort order
  Future<int> getNextSortOrder() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('sortOrder', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return 1;
      }
      
      final lastCategory = CategoryModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
      return lastCategory.sortOrder + 1;
    } catch (e) {
      throw Exception('Failed to get next sort order: $e');
    }
  }
}

