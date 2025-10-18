import 'package:flutter/material.dart';

/// Stock level value object
class StockLevel {
  final int quantity;
  final int lowStockThreshold;

  const StockLevel({
    required this.quantity,
    required this.lowStockThreshold,
  });

  /// Check if stock is available
  bool get isInStock => quantity > 0;

  /// Check if stock is out
  bool get isOutOfStock => quantity <= 0;

  /// Check if stock is low
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;

  /// Get stock status
  StockStatus get status {
    if (isOutOfStock) {
      return StockStatus.outOfStock;
    } else if (isLowStock) {
      return StockStatus.lowStock;
    } else {
      return StockStatus.inStock;
    }
  }

  /// Get stock status color
  Color get statusColor {
    switch (status) {
      case StockStatus.inStock:
        return Colors.green;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }

  /// Get stock status text
  String get statusText {
    switch (status) {
      case StockStatus.inStock:
        return 'متوفر'; // In stock
      case StockStatus.lowStock:
        return 'مخزون منخفض'; // Low stock
      case StockStatus.outOfStock:
        return 'غير متوفر'; // Out of stock
    }
  }

  /// Get stock status icon
  IconData get statusIcon {
    switch (status) {
      case StockStatus.inStock:
        return Icons.check_circle;
      case StockStatus.lowStock:
        return Icons.warning;
      case StockStatus.outOfStock:
        return Icons.cancel;
    }
  }
}

/// Stock status enum
enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
}

