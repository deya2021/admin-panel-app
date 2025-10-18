import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/utils/validators.dart';
import '../providers/product_providers.dart';
import '../models/product_model.dart';

/// Add or edit product screen
class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({
    Key? key,
    this.productId,
  }) : super(key: key);

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryIdController = TextEditingController();
  
  bool _isActive = true;
  bool _isLoading = false;
  XFile? _selectedImage;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryIdController.dispose();
    super.dispose();
  }

  /// Load existing product data
  Future<void> _loadProduct() async {
    try {
      final product = await ref
          .read(productRepositoryProvider)
          .getProductById(widget.productId!);
      
      if (product != null && mounted) {
        setState(() {
          _nameController.text = product.name;
          _descriptionController.text = product.description;
          _priceController.text = product.price.toString();
          _stockController.text = product.stockQuantity.toString();
          _categoryIdController.text = product.categoryId;
          _isActive = product.isActive;
          _existingImageUrl = product.imageUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل المنتج: $e')),
        );
      }
    }
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل اختيار الصورة: $e')),
        );
      }
    }
  }

  /// Save product
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      
      // Upload image if selected
      String? imageUrl = _existingImageUrl;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final fileName = _selectedImage!.name;
        imageUrl = await repository.uploadProductImageBytes(bytes, fileName);
      }

      // Prepare product data
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'stockQuantity': int.parse(_stockController.text.trim()),
        'categoryId': _categoryIdController.text.trim(),
        'isActive': _isActive,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      if (widget.productId != null) {
        // Update existing product
        await repository.updateProductFromMap(widget.productId!, productData);
      } else {
        // Create new product
        await repository.createProductFromMap(productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.productId != null
                  ? 'تم تحديث المنتج بنجاح'
                  : 'تم إضافة المنتج بنجاح',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حفظ المنتج: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل المنتج' : 'إضافة منتج'), // Edit/Add Product
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'حفظ', // Save
              onPressed: _saveProduct,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kIsWeb
                                      ? Image.network(
                                          _selectedImage!.path,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(_selectedImage!.path),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : _existingImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _existingImageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate,
                                            size: 48, color: Colors.grey[600]),
                                        const SizedBox(height: 8),
                                        Text(
                                          'اختر صورة', // Choose image
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المنتج', // Product name
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      validator: Validators.required,
                    ),

                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'الوصف', // Description
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: Validators.required,
                    ),

                    const SizedBox(height: 16),

                    // Price Field
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'السعر (د.م)', // Price (MRU)
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        if (double.tryParse(value) == null) {
                          return 'أدخل رقماً صحيحاً';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Stock Field
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'المخزون', // Stock
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
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

                    const SizedBox(height: 16),

                    // Category ID Field
                    TextFormField(
                      controller: _categoryIdController,
                      decoration: const InputDecoration(
                        labelText: 'معرف الفئة', // Category ID
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: Validators.required,
                    ),

                    const SizedBox(height: 16),

                    // Active Switch
                    SwitchListTile(
                      title: const Text('نشط'), // Active
                      subtitle: const Text('هل المنتج متاح للبيع؟'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProduct,
                      icon: const Icon(Icons.save),
                      label: Text(isEdit ? 'تحديث المنتج' : 'إضافة المنتج'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

