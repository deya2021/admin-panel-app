import 'dart:typed_data';
import 'dart:io'; // ملاحظة: إن كنت تستهدف الويب، احذف هذا السطر واستخدم طريقة الرفع بالبايتات فقط.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product_model.dart';

/// Repository for product management operations
class ProductRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final String _collection = 'products';
  final String _storagePath = 'product_images';

  ProductRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // ===== Streams =====

  /// Get stream of all products
  Stream<List<ProductModel>> getProductsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of active products
  Stream<List<ProductModel>> getActiveProductsStream() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of products by category
  Stream<List<ProductModel>> getProductsByCategoryStream(String categoryId) {
    return _firestore
        .collection(_collection)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of low stock products
  Stream<List<ProductModel>> getLowStockProductsStream() {
    return _firestore
        .collection(_collection)
        .where('stockQuantity', isLessThan: 10)
        .orderBy('stockQuantity')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get stream of out of stock products
  Stream<List<ProductModel>> getOutOfStockProductsStream() {
    return _firestore
        .collection(_collection)
        .where('stockQuantity', isEqualTo: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ===== Single doc =====

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      if (doc.exists && doc.data() != null) {
        return ProductModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  /// Get stream of product by ID
  Stream<ProductModel?> getProductByIdStream(String productId) {
    return _firestore
        .collection(_collection)
        .doc(productId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return ProductModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // ===== CRUD =====

  /// Create product
  Future<String> createProduct(ProductModel product) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(product.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).update({
        ...product.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Update product stock
  Future<void> updateStock(String productId, int quantity) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'stockQuantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  /// Increment product stock
  Future<void> incrementStock(String productId, int amount) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'stockQuantity': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to increment stock: $e');
    }
  }

  /// Decrement product stock
  Future<void> decrementStock(String productId, int amount) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'stockQuantity': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to decrement stock: $e');
    }
  }

  /// Update product active status
  Future<void> updateActiveStatus(String productId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update active status: $e');
    }
  }

  /// Delete product (and image if exists)
  Future<void> deleteProduct(String productId) async {
    try {
      // Get product to delete image
      final product = await getProductById(productId);

      // Delete image from storage if exists
      if (product?.imageUrl != null && product!.imageUrl!.isNotEmpty) {
        try {
          await deleteProductImage(product.imageUrl!);
        } catch (_) {
          // نتجاهل فشل حذف الصورة حتى لا يوقف حذف الوثيقة
        }
      }

      // Delete product document
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ===== Storage =====

  /// Upload product image (File) — للمنصات غير الويب
  Future<String> uploadProductImage(String productId, File imageFile) async {
    try {
      final fileName =
          '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(_storagePath).child(fileName);

      final task = await ref.putFile(imageFile);
      final downloadUrl = await task.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload product image: $e');
    }
  }

  /// Upload product image from bytes (للويب/الهاتف بدون File)
  Future<String> uploadProductImageBytes(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageName = 'products/${timestamp}_$fileName';
      final ref = _storage.ref().child(storageName);

      final task = await ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await task.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload product image: $e');
    }
  }

  /// Delete product image from storage
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete product image: $e');
    }
  }

  // ===== Queries / Counts =====

  /// Search products by name (prefix search)
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name') // 🔴 ضروري مع نطاق >= <=
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Get product count
  Future<int> getProductCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get product count: $e');
    }
  }

  /// Get active product count
  Future<int> getActiveProductCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get active product count: $e');
    }
  }

  /// Get low stock product count
  Future<int> getLowStockCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('stockQuantity', isLessThan: 10)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get low stock count: $e');
    }
  }

  // ===== Helper methods for UI operations =====

  /// Create product from map (for UI forms)
  Future<String> createProductFromMap(Map<String, dynamic> productData) async {
    try {
      final data = {
        ...productData,
        'pointsRate': productData['pointsRate'] ?? 0.02, // Default 2%
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final docRef = await _firestore.collection(_collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update product from map (for UI forms)
  Future<void> updateProductFromMap(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    try {
      final data = {
        ...productData,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection(_collection).doc(productId).update(data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }
}
