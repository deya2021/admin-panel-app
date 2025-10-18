import 'package:intl/intl.dart';

/// Formatting utilities for dates, numbers, and currency
class Formatters {
  Formatters._();

  /// Format date to Arabic format
  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  /// Format date and time to Arabic format
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm', 'ar').format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm', 'ar').format(dateTime);
  }

  /// Format relative time (e.g., "منذ ساعتين")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن'; // Now
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'منذ $minutes دقيقة'; // X minutes ago
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'منذ $hours ساعة'; // X hours ago
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'منذ $days يوم'; // X days ago
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks أسبوع'; // X weeks ago
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months شهر'; // X months ago
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years سنة'; // X years ago
    }
  }

  /// Format currency (MRU - Mauritanian Ouguiya)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'ar',
      symbol: 'أوقية', // MRU symbol in Arabic
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format number with thousands separator
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,##0', 'ar');
    return formatter.format(number);
  }

  /// Format decimal number
  static String formatDecimal(double number, {int decimalPlaces = 2}) {
    final formatter = NumberFormat.decimalPattern('ar');
    return formatter.format(number);
  }

  /// Format percentage
  static String formatPercentage(double value) {
    final formatter = NumberFormat.percentPattern('ar');
    return formatter.format(value);
  }

  /// Format points
  static String formatPoints(int points) {
    return '$points نقطة'; // X points
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes بايت'; // bytes
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(2);
      return '$kb كيلوبايت'; // KB
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
      return '$mb ميجابايت'; // MB
    } else {
      final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(2);
      return '$gb جيجابايت'; // GB
    }
  }

  /// Format phone number
  static String formatPhoneNumber(String phone) {
    // Remove non-digit characters
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    
    // Format as +XXX XXXX XXXX
    if (digits.length >= 10) {
      final countryCode = digits.substring(0, digits.length - 9);
      final part1 = digits.substring(digits.length - 9, digits.length - 6);
      final part2 = digits.substring(digits.length - 6, digits.length - 3);
      final part3 = digits.substring(digits.length - 3);
      return '+$countryCode $part1 $part2 $part3';
    }
    
    return phone;
  }
}

