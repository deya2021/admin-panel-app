import 'package:cloud_firestore/cloud_firestore.dart';

/// Product model representing a product in the store
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String categoryId;
  final int stockQuantity;
  final double pointsRate; // Points earned per unit of currency (e.g., 2% = 0.02)
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    required this.stockQuantity,
    this.pointsRate = 0.02, // Default 2%
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Create ProductModel from Firestore document
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] as String?,
      categoryId: map['categoryId'] as String? ?? '',
      stockQuantity: map['stockQuantity'] as int? ?? 0,
      pointsRate: (map['pointsRate'] as num?)?.toDouble() ?? 0.02,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert ProductModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'stockQuantity': stockQuantity,
      'pointsRate': pointsRate,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    int? stockQuantity,
    double? pointsRate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      pointsRate: pointsRate ?? this.pointsRate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if product is low stock (less than 10 units)
  bool get isLowStock => stockQuantity < 10;

  /// Check if product is out of stock
  bool get isOutOfStock => stockQuantity <= 0;

  /// Get stock status
  String get stockStatus {
    if (isOutOfStock) return 'نفذ من المخزون'; // Out of stock
    if (isLowStock) return 'مخزون منخفض'; // Low stock
    return 'متوفر'; // Available
  }

  /// Calculate points earned for this product
  double calculatePoints(double amount) {
    return amount * pointsRate;
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, stock: $stockQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ProductModel &&
      other.id == id &&
      other.name == name &&
      other.price == price;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode;
}

