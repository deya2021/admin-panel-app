class OrderModel {
  final String id;
  final String userId;
  final double total;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  // fromMap بدون استخدام Timestamp
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'pending',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic date) {
    if (date is DateTime) return date;

    // إذا كان Timestamp لكن لا نستطيع استيراده، استخدم DateTime مباشرة
    if (date != null) {
      try {
        // حاول تحويل أي قيمة إلى DateTime
        return date.toDate(); // إذا كان فيه toDate()
      } catch (e) {
        // إذا فشل، استخدم التاريخ الحالي
        return DateTime.now();
      }
    }

    return DateTime.now();
  }
}
