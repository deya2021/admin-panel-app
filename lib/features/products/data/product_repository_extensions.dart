import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../data/product_repository.dart';

/// Extension methods for ProductRepository to support UI operations
extension ProductRepositoryExtensions on ProductRepository {
  /// Create product from map (for UI forms)
  Future<String> createProductFromMap(Map<String, dynamic> productData) async {
    try {
      final data = {
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final docRef =
          await FirebaseFirestore.instance.collection('products').add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update product from map (for UI forms)
  Future<void> updateProductFromMap(
      String productId, Map<String, dynamic> productData) async {
    try {
      final data = {
        ...productData,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Upload product image from bytes (for web and mobile)
  Future<String> uploadProductImageBytes(
      List<int> bytes, String fileName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageName = 'products/${timestamp}_$fileName';
      final ref = FirebaseStorage.instance.ref().child(storageName);

      final uploadTask = await ref.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload product image: $e');
    }
  }
}
