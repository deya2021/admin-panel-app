import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/utils/validators.dart';
import '../providers/category_providers.dart';
import '../models/category_model.dart';

/// Category management screen
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفئات'), // Categories
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة فئة', // Add category
            onPressed: () => _showAddEditDialog(context, ref),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyView(
              message: 'لا توجد فئات', // No categories
              icon: Icons.category_outlined,
              actionLabel: 'إضافة فئة', // Add category
              onAction: () => _showAddEditDialog(context, ref),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(categoriesStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(context, ref, category);
              },
            ),
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorView(
          error: error.toString(),
          onRetry: () => ref.invalidate(categoriesStreamProvider),
        ),
      ),
    );
  }

  /// Build category card
  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.category,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('الترتيب: ${category.sortOrder}'), // Sort order
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'تعديل', // Edit
              onPressed: () => _showAddEditDialog(context, ref, category: category),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'حذف', // Delete
              color: Colors.red,
              onPressed: () => _confirmDelete(context, ref, category),
            ),
          ],
        ),
      ),
    );
  }

  /// Show add/edit dialog
  Future<void> _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    CategoryModel? category,
  }) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category?.name);
    final sortOrderController = TextEditingController(
      text: category?.sortOrder.toString(),
    );

    // Get next sort order if adding new category
    if (category == null) {
      final nextSortOrder = await ref.read(nextSortOrderProvider.future);
      sortOrderController.text = nextSortOrder.toString();
    }

    if (!context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'إضافة فئة' : 'تعديل فئة'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الفئة', // Category name
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: Validators.required,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: sortOrderController,
                decoration: const InputDecoration(
                  labelText: 'الترتيب', // Sort order
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sort),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  if (int.tryParse(value) == null) {
                    return 'أدخل رقماً صحيحاً';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'), // Cancel
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final repository = ref.read(categoryRepositoryProvider);
                  final name = nameController.text.trim();
                  final sortOrder = int.parse(sortOrderController.text.trim());

                  if (category == null) {
                    await repository.createCategory(name, sortOrder);
                  } else {
                    await repository.updateCategory(category.id, name, sortOrder);
                  }

                  if (context.mounted) {
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          category == null
                              ? 'تم إضافة الفئة بنجاح'
                              : 'تم تحديث الفئة بنجاح',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('فشل حفظ الفئة: $e')),
                    );
                  }
                }
              }
            },
            child: Text(category == null ? 'إضافة' : 'تحديث'),
          ),
        ],
      ),
    );

    nameController.dispose();
    sortOrderController.dispose();
  }

  /// Confirm delete dialog
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'), // Confirm Delete
        content: Text('هل أنت متأكد من حذف "${category.name}"؟'), // Are you sure?
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'), // Cancel
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'), // Delete
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الفئة بنجاح')), // Category deleted
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل حذف الفئة: $e')), // Failed to delete
          );
        }
      }
    }
  }
}

