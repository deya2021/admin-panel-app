import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/category_repository.dart';
import '../models/category_model.dart';

/// Provider for CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// Provider for categories stream
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategoriesStream();
});

/// Provider for category count
final categoryCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategoryCount();
});

/// Provider for next sort order
final nextSortOrderProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getNextSortOrder();
});

