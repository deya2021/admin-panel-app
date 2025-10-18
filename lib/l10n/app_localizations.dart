import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة إدارة متجر البقالة'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @enterEmail.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البريد الإلكتروني'**
  String get enterEmail;

  /// No description provided for @enterPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الهاتف'**
  String get enterPhone;

  /// No description provided for @enterPassword.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صحيح'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة جداً'**
  String get passwordTooShort;

  /// No description provided for @loginSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول بنجاح'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول'**
  String get loginFailed;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signUp;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً'**
  String get welcome;

  /// No description provided for @statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statistics;

  /// No description provided for @totalProducts.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المنتجات'**
  String get totalProducts;

  /// No description provided for @totalCategories.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الفئات'**
  String get totalCategories;

  /// No description provided for @totalUsers.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستخدمين'**
  String get totalUsers;

  /// No description provided for @totalOrders.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الطلبات'**
  String get totalOrders;

  /// No description provided for @pendingRedemptions.
  ///
  /// In ar, this message translates to:
  /// **'الاستبدالات المعلقة'**
  String get pendingRedemptions;

  /// No description provided for @totalPoints.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي النقاط'**
  String get totalPoints;

  /// No description provided for @activeProducts.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات النشطة'**
  String get activeProducts;

  /// No description provided for @lowStockProducts.
  ///
  /// In ar, this message translates to:
  /// **'منتجات منخفضة المخزون'**
  String get lowStockProducts;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة'**
  String get quickActions;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @recentActivity.
  ///
  /// In ar, this message translates to:
  /// **'النشاط الأخير'**
  String get recentActivity;

  /// No description provided for @products.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get products;

  /// No description provided for @product.
  ///
  /// In ar, this message translates to:
  /// **'منتج'**
  String get product;

  /// No description provided for @addProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In ar, this message translates to:
  /// **'تعديل منتج'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In ar, this message translates to:
  /// **'حذف منتج'**
  String get deleteProduct;

  /// No description provided for @productName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج'**
  String get productName;

  /// No description provided for @productDescription.
  ///
  /// In ar, this message translates to:
  /// **'وصف المنتج'**
  String get productDescription;

  /// No description provided for @productPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get productPrice;

  /// No description provided for @productStock.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المتوفرة'**
  String get productStock;

  /// No description provided for @productCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get productCategory;

  /// No description provided for @productImage.
  ///
  /// In ar, this message translates to:
  /// **'صورة المنتج'**
  String get productImage;

  /// No description provided for @productImages.
  ///
  /// In ar, this message translates to:
  /// **'صور المنتج'**
  String get productImages;

  /// No description provided for @pointsRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة النقاط'**
  String get pointsRate;

  /// No description provided for @lowStockThreshold.
  ///
  /// In ar, this message translates to:
  /// **'حد المخزون المنخفض'**
  String get lowStockThreshold;

  /// No description provided for @isActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get isActive;

  /// No description provided for @enterProductName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المنتج'**
  String get enterProductName;

  /// No description provided for @enterProductDescription.
  ///
  /// In ar, this message translates to:
  /// **'أدخل وصف المنتج'**
  String get enterProductDescription;

  /// No description provided for @enterProductPrice.
  ///
  /// In ar, this message translates to:
  /// **'أدخل السعر'**
  String get enterProductPrice;

  /// No description provided for @enterProductStock.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الكمية'**
  String get enterProductStock;

  /// No description provided for @enterPointsRate.
  ///
  /// In ar, this message translates to:
  /// **'أدخل نسبة النقاط (مثال: 0.02 = 2%)'**
  String get enterPointsRate;

  /// No description provided for @enterLowStockThreshold.
  ///
  /// In ar, this message translates to:
  /// **'أدخل حد المخزون المنخفض'**
  String get enterLowStockThreshold;

  /// No description provided for @selectCategory.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئة'**
  String get selectCategory;

  /// No description provided for @uploadImage.
  ///
  /// In ar, this message translates to:
  /// **'رفع صورة'**
  String get uploadImage;

  /// No description provided for @changeImage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get changeImage;

  /// No description provided for @productAdded.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة المنتج بنجاح'**
  String get productAdded;

  /// No description provided for @productUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المنتج بنجاح'**
  String get productUpdated;

  /// No description provided for @productDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المنتج بنجاح'**
  String get productDeleted;

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المنتج؟'**
  String get confirmDeleteProduct;

  /// No description provided for @noProducts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات'**
  String get noProducts;

  /// No description provided for @searchProducts.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن منتجات'**
  String get searchProducts;

  /// No description provided for @filterByCategory.
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب الفئة'**
  String get filterByCategory;

  /// No description provided for @allCategories.
  ///
  /// In ar, this message translates to:
  /// **'جميع الفئات'**
  String get allCategories;

  /// No description provided for @inStock.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get outOfStock;

  /// No description provided for @lowStock.
  ///
  /// In ar, this message translates to:
  /// **'مخزون منخفض'**
  String get lowStock;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get categories;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'فئة'**
  String get category;

  /// No description provided for @addCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فئة'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In ar, this message translates to:
  /// **'تعديل فئة'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In ar, this message translates to:
  /// **'حذف فئة'**
  String get deleteCategory;

  /// No description provided for @categoryName.
  ///
  /// In ar, this message translates to:
  /// **'اسم الفئة'**
  String get categoryName;

  /// No description provided for @categoryOrder.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب'**
  String get categoryOrder;

  /// No description provided for @enterCategoryName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم الفئة'**
  String get enterCategoryName;

  /// No description provided for @enterCategoryOrder.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الترتيب'**
  String get enterCategoryOrder;

  /// No description provided for @categoryAdded.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الفئة بنجاح'**
  String get categoryAdded;

  /// No description provided for @categoryUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الفئة بنجاح'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الفئة بنجاح'**
  String get categoryDeleted;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه الفئة؟'**
  String get confirmDeleteCategory;

  /// No description provided for @noCategories.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات'**
  String get noCategories;

  /// No description provided for @redemptions.
  ///
  /// In ar, this message translates to:
  /// **'الاستبدالات'**
  String get redemptions;

  /// No description provided for @redemption.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get redemption;

  /// No description provided for @pendingRedemption.
  ///
  /// In ar, this message translates to:
  /// **'استبدال معلق'**
  String get pendingRedemption;

  /// No description provided for @approvedRedemption.
  ///
  /// In ar, this message translates to:
  /// **'استبدال موافق عليه'**
  String get approvedRedemption;

  /// No description provided for @rejectedRedemption.
  ///
  /// In ar, this message translates to:
  /// **'استبدال مرفوض'**
  String get rejectedRedemption;

  /// No description provided for @completedRedemption.
  ///
  /// In ar, this message translates to:
  /// **'استبدال مكتمل'**
  String get completedRedemption;

  /// No description provided for @approveRedemption.
  ///
  /// In ar, this message translates to:
  /// **'الموافقة على الاستبدال'**
  String get approveRedemption;

  /// No description provided for @rejectRedemption.
  ///
  /// In ar, this message translates to:
  /// **'رفض الاستبدال'**
  String get rejectRedemption;

  /// No description provided for @completeRedemption.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الاستبدال'**
  String get completeRedemption;

  /// No description provided for @redemptionStatus.
  ///
  /// In ar, this message translates to:
  /// **'حالة الاستبدال'**
  String get redemptionStatus;

  /// No description provided for @redemptionPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط الاستبدال'**
  String get redemptionPoints;

  /// No description provided for @redemptionNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get redemptionNote;

  /// No description provided for @userName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get userName;

  /// No description provided for @userPhone.
  ///
  /// In ar, this message translates to:
  /// **'هاتف المستخدم'**
  String get userPhone;

  /// No description provided for @requestDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الطلب'**
  String get requestDate;

  /// No description provided for @reviewDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ المراجعة'**
  String get reviewDate;

  /// No description provided for @reviewer.
  ///
  /// In ar, this message translates to:
  /// **'المراجع'**
  String get reviewer;

  /// No description provided for @enterNote.
  ///
  /// In ar, this message translates to:
  /// **'أدخل ملاحظة (اختياري)'**
  String get enterNote;

  /// No description provided for @redemptionApproved.
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة على الاستبدال'**
  String get redemptionApproved;

  /// No description provided for @redemptionRejected.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الاستبدال'**
  String get redemptionRejected;

  /// No description provided for @redemptionCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم إكمال الاستبدال'**
  String get redemptionCompleted;

  /// No description provided for @confirmApprove.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من الموافقة على هذا الاستبدال؟'**
  String get confirmApprove;

  /// No description provided for @confirmReject.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رفض هذا الاستبدال؟'**
  String get confirmReject;

  /// No description provided for @confirmComplete.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من إكمال هذا الاستبدال؟'**
  String get confirmComplete;

  /// No description provided for @noRedemptions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد استبدالات'**
  String get noRedemptions;

  /// No description provided for @filterByStatus.
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب الحالة'**
  String get filterByStatus;

  /// No description provided for @allStatuses.
  ///
  /// In ar, this message translates to:
  /// **'جميع الحالات'**
  String get allStatuses;

  /// No description provided for @pending.
  ///
  /// In ar, this message translates to:
  /// **'معلق'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In ar, this message translates to:
  /// **'موافق عليه'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get rejected;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completed;

  /// No description provided for @users.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get users;

  /// No description provided for @user.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get user;

  /// No description provided for @staffManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الموظفين'**
  String get staffManagement;

  /// No description provided for @userRole.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get userRole;

  /// No description provided for @setRole.
  ///
  /// In ar, this message translates to:
  /// **'تعيين الدور'**
  String get setRole;

  /// No description provided for @changeRole.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الدور'**
  String get changeRole;

  /// No description provided for @admin.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get admin;

  /// No description provided for @manager.
  ///
  /// In ar, this message translates to:
  /// **'مشرف'**
  String get manager;

  /// No description provided for @regularUser.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم عادي'**
  String get regularUser;

  /// No description provided for @roleUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الدور بنجاح'**
  String get roleUpdated;

  /// No description provided for @confirmRoleChange.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تغيير دور هذا المستخدم؟'**
  String get confirmRoleChange;

  /// No description provided for @noUsers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمون'**
  String get noUsers;

  /// No description provided for @searchUsers.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن مستخدمين'**
  String get searchUsers;

  /// No description provided for @filterByRole.
  ///
  /// In ar, this message translates to:
  /// **'تصفية حسب الدور'**
  String get filterByRole;

  /// No description provided for @allRoles.
  ///
  /// In ar, this message translates to:
  /// **'جميع الأدوار'**
  String get allRoles;

  /// No description provided for @totalPointsEarned.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي النقاط المكتسبة'**
  String get totalPointsEarned;

  /// No description provided for @totalPointsRedeemed.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي النقاط المستبدلة'**
  String get totalPointsRedeemed;

  /// No description provided for @availablePoints.
  ///
  /// In ar, this message translates to:
  /// **'النقاط المتاحة'**
  String get availablePoints;

  /// No description provided for @memberSince.
  ///
  /// In ar, this message translates to:
  /// **'عضو منذ'**
  String get memberSince;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @notification.
  ///
  /// In ar, this message translates to:
  /// **'إشعار'**
  String get notification;

  /// No description provided for @notificationCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز الإشعارات'**
  String get notificationCenter;

  /// No description provided for @sendNotification.
  ///
  /// In ar, this message translates to:
  /// **'إرسال إشعار'**
  String get sendNotification;

  /// No description provided for @notificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الإشعار'**
  String get notificationTitle;

  /// No description provided for @notificationBody.
  ///
  /// In ar, this message translates to:
  /// **'محتوى الإشعار'**
  String get notificationBody;

  /// No description provided for @sendToAll.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للجميع'**
  String get sendToAll;

  /// No description provided for @sendToAdmins.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمديرين'**
  String get sendToAdmins;

  /// No description provided for @sendToManagers.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمشرفين'**
  String get sendToManagers;

  /// No description provided for @enterNotificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان الإشعار'**
  String get enterNotificationTitle;

  /// No description provided for @enterNotificationBody.
  ///
  /// In ar, this message translates to:
  /// **'أدخل محتوى الإشعار'**
  String get enterNotificationBody;

  /// No description provided for @notificationSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الإشعار بنجاح'**
  String get notificationSent;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get noNotifications;

  /// No description provided for @markAsRead.
  ///
  /// In ar, this message translates to:
  /// **'وضع علامة كمقروء'**
  String get markAsRead;

  /// No description provided for @markAllAsRead.
  ///
  /// In ar, this message translates to:
  /// **'وضع علامة على الكل كمقروء'**
  String get markAllAsRead;

  /// No description provided for @deleteNotification.
  ///
  /// In ar, this message translates to:
  /// **'حذف الإشعار'**
  String get deleteNotification;

  /// No description provided for @newRedemptionAlert.
  ///
  /// In ar, this message translates to:
  /// **'طلب استبدال جديد'**
  String get newRedemptionAlert;

  /// No description provided for @lowStockAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه مخزون منخفض'**
  String get lowStockAlert;

  /// No description provided for @redemptionStatusUpdate.
  ///
  /// In ar, this message translates to:
  /// **'تحديث حالة الاستبدال'**
  String get redemptionStatusUpdate;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجاح'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In ar, this message translates to:
  /// **'معلومات'**
  String get info;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optional;

  /// No description provided for @selectAll.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء تحديد الكل'**
  String get deselectAll;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @tryAgain.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة أخرى'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما'**
  String get somethingWentWrong;

  /// No description provided for @connectionError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال'**
  String get connectionError;

  /// No description provided for @permissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض الإذن'**
  String get permissionDenied;

  /// No description provided for @notAuthorized.
  ///
  /// In ar, this message translates to:
  /// **'غير مصرح'**
  String get notAuthorized;

  /// No description provided for @adminOnly.
  ///
  /// In ar, this message translates to:
  /// **'للمديرين فقط'**
  String get adminOnly;

  /// No description provided for @managerOrAbove.
  ///
  /// In ar, this message translates to:
  /// **'للمشرفين والمديرين فقط'**
  String get managerOrAbove;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @invalidValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة غير صحيحة'**
  String get invalidValue;

  /// No description provided for @valueTooLow.
  ///
  /// In ar, this message translates to:
  /// **'القيمة منخفضة جداً'**
  String get valueTooLow;

  /// No description provided for @valueTooHigh.
  ///
  /// In ar, this message translates to:
  /// **'القيمة مرتفعة جداً'**
  String get valueTooHigh;

  /// No description provided for @invalidFormat.
  ///
  /// In ar, this message translates to:
  /// **'تنسيق غير صحيح'**
  String get invalidFormat;

  /// No description provided for @mustBeNumber.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون رقماً'**
  String get mustBeNumber;

  /// No description provided for @mustBePositive.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون موجباً'**
  String get mustBePositive;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الماضي'**
  String get lastMonth;

  /// No description provided for @createdAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التحديث'**
  String get updatedAt;

  /// No description provided for @view.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get view;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get create;

  /// No description provided for @remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get remove;

  /// No description provided for @activate.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التفعيل'**
  String get deactivate;

  /// No description provided for @enable.
  ///
  /// In ar, this message translates to:
  /// **'تمكين'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل'**
  String get disable;

  /// No description provided for @approve.
  ///
  /// In ar, this message translates to:
  /// **'موافقة'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get reject;

  /// No description provided for @complete.
  ///
  /// In ar, this message translates to:
  /// **'إكمال'**
  String get complete;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @download.
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// No description provided for @upload.
  ///
  /// In ar, this message translates to:
  /// **'رفع'**
  String get upload;

  /// No description provided for @export.
  ///
  /// In ar, this message translates to:
  /// **'تصدير'**
  String get export;

  /// No description provided for @import.
  ///
  /// In ar, this message translates to:
  /// **'استيراد'**
  String get import;

  /// No description provided for @print.
  ///
  /// In ar, this message translates to:
  /// **'طباعة'**
  String get print;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
