import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product_repository.dart';
import '../models/product_model.dart';

/// Provider for ProductRepository
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Provider for all products stream
final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsStream();
});

/// Provider for active products stream
final activeProductsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getActiveProductsStream();
});

/// Provider for products by category stream
final productsByCategoryStreamProvider = StreamProvider.family<List<ProductModel>, String>((ref, categoryId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsByCategoryStream(categoryId);
});

/// Provider for low stock products stream
final lowStockProductsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getLowStockProductsStream();
});

/// Provider for out of stock products stream
final outOfStockProductsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getOutOfStockProductsStream();
});

/// Provider for product by ID stream
final productByIdStreamProvider = StreamProvider.family<ProductModel?, String>((ref, productId) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductByIdStream(productId);
});

/// Provider for total products count
final totalProductsCountProvider = Provider<int>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);
  return productsAsync.when(
    data: (products) => products.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for active products count
final activeProductsCountProvider = Provider<int>((ref) {
  final productsAsync = ref.watch(activeProductsStreamProvider);
  return productsAsync.when(
    data: (products) => products.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for low stock count
final lowStockCountProvider = Provider<int>((ref) {
  final productsAsync = ref.watch(lowStockProductsStreamProvider);
  return productsAsync.when(
    data: (products) => products.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for out of stock count
final outOfStockCountProvider = Provider<int>((ref) {
  final productsAsync = ref.watch(outOfStockProductsStreamProvider);
  return productsAsync.when(
    data: (products) => products.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider for total inventory value
final totalInventoryValueProvider = Provider<double>((ref) {
  final productsAsync = ref.watch(productsStreamProvider);
  return productsAsync.when(
    data: (products) {
      return products.fold<double>(
        0.0,
        (sum, product) => sum + (product.price * product.stockQuantity),
      );
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

