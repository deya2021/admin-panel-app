import 'package:cloud_firestore/cloud_firestore.dart';

/// Category model for product categories
class CategoryModel {
  final String id;
  final String name;
  final int sortOrder;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.createdAt,
  });

  /// Create CategoryModel from Firestore document
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
      sortOrder: map['sortOrder'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert CategoryModel to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Copy with method
  CategoryModel copyWith({
    String? id,
    String? name,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

