/// Application constants
class AppConstants {
  AppConstants._();

  // App metadata
  static const String appName = 'لوحة إدارة متجر البقالة';
  static const String appVersion = '1.0.0';

  // Firebase collections
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String redemptionsCollection = 'redemptions';
  static const String usersCollection = 'users';
  static const String ordersCollection = 'orders';
  static const String statsCollection = 'stats';
  static const String notificationsCollection = 'notifications';

  // Firebase Storage paths
  static const String productImagesPath = 'product_images';
  static const String categoryImagesPath = 'category_images';

  // FCM topics
  static const String adminAlertsTopic = 'admin_alerts';
  static const String managerAlertsTopic = 'manager_alerts';

  // Default values
  static const double defaultPointsRate = 0.02; // 2%
  static const int defaultLowStockThreshold = 5;
  static const int defaultPageSize = 20;

  // Validation limits
  static const int minPasswordLength = 6;
  static const int maxProductNameLength = 100;
  static const int maxProductDescriptionLength = 500;
  static const int maxCategoryNameLength = 50;
  static const double maxProductPrice = 1000000.0;
  static const int maxStockQuantity = 100000;
  static const double maxPointsRate = 1.0; // 100%

  // Image upload limits
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxItemsPerPage = 100;

  // Cache durations
  static const Duration shortCacheDuration = Duration(minutes: 5);
  static const Duration mediumCacheDuration = Duration(minutes: 30);
  static const Duration longCacheDuration = Duration(hours: 24);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;
  static const double maxContentWidth = 1200.0;

  // Grid layout
  static const int mobileColumns = 1;
  static const int tabletColumns = 2;
  static const int desktopColumns = 3;

  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}

