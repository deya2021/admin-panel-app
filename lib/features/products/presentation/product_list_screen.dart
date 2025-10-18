import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/empty_view.dart';
import '../providers/product_providers.dart';
import '../models/product_model.dart';

/// Product list screen for managing products
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync =
        ref.watch(productsStreamProvider); // ✅ نستخدم ref من ConsumerState

    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة منتج',
            onPressed: () => context.push('/products/add'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Products List
          Expanded(
            child: productsAsync.when(
              data: (products) {
                // Filter products by search query (مع حماية الوصف إن كان null)
                final filteredProducts = products.where((product) {
                  final name = product.name.toLowerCase();
                  final desc = (product.description ?? '').toLowerCase();
                  return name.contains(_searchQuery) ||
                      desc.contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return EmptyView(
                    message: _searchQuery.isEmpty
                        ? 'لا توجد منتجات'
                        : 'لا توجد نتائج للبحث',
                    icon: Icons.inventory_2_outlined,
                    actionLabel: _searchQuery.isEmpty ? 'إضافة منتج' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => context.push('/products/add')
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(productsStreamProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stack) => ErrorView(
                error: error.toString(), // ✅ ErrorView يحتاج error
                onRetry: () => ref.invalidate(productsStreamProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build product card
  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(product.imageUrl!),
                backgroundColor: Colors.grey[200],
              )
            : CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.image, color: Colors.grey[400]),
              ),
        title: Text(
          product.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if ((product.description ?? '').isNotEmpty)
              Text(
                product.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(
                  label: '${product.price.toStringAsFixed(2)} د.م',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildChip(
                  label: 'المخزون: ${product.stockQuantity}',
                  icon: Icons.inventory_2,
                  color: product.stockQuantity <= 5 ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                if (!product.isActive)
                  _buildChip(
                    label: 'غير نشط',
                    icon: Icons.block,
                    color: Colors.grey,
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'تعديل',
              onPressed: () => context.push('/products/edit/${product.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'حذف',
              color: Colors.red,
              onPressed: () => _confirmDelete(context, product),
            ),
          ],
        ),
      ),
    );
  }

  /// Build chip widget
  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Confirm delete dialog
  Future<void> _confirmDelete(
      BuildContext context, ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(productRepositoryProvider).deleteProduct(product.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المنتج بنجاح')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل حذف المنتج: $e')),
          );
        }
      }
    }
  }
}
