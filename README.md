# RationPoint Admin Panel

لوحة تحكم إدارية لنظام إدارة النقاط والمكافآت

## المميزات الرئيسية
- 📊 لوحة تحكم تفاعلية مع إحصائيات فورية
- 👥 إدارة المستخدمين والصلاحيات
- 📦 إدارة المنتجات والمخزون
- 🎁 نظام النقاط والاسترداد
- 📈 تتبع الطلبات الأسبوعية
- 🔄 تحديث تلقائي للبيانات في الوقت الفعلي

## التحديثات الأخيرة (Latest Updates)

### تحسين نظام الإحصائيات والطلبات الأسبوعية

#### 1. Cloud Functions المحسّنة
- ✅ **دالة updateStats**: تحديث تلقائي للإحصائيات عند أي تغيير في المستخدمين/المنتجات/الطلبات
- ✅ **weeklyOrders**: يتم حساب عدد الطلبات لآخر 7 أيام (دائماً 7 أعداد صحيحة)
  - Index 0: قبل 6 أيام (أقدم)
  - Index 6: اليوم (أحدث)
- ✅ **دالة recalcWeekly**: دالة جديدة قابلة للاستدعاء لإعادة حساب الطلبات الأسبوعية يدوياً
  - متاحة للمديرين فقط (admin role)
  - تحديث فوري للبيانات

#### 2. تحسين تدفق البيانات
- ✅ استخدام StreamProvider لتحديث فوري عند تغيير stats/main
- ✅ إزالة جميع عبارات print واستبدالها بتدفق البيانات الصامت
- ✅ معالجة أفضل للأخطاء مع fallback للبيانات الوهمية
- ✅ التأكد من أن weeklyOrders دائماً يحتوي على 7 عناصر

#### 3. تنظيف الكود (Code Cleanup)
- ✅ إصلاح جميع تحذيرات `use_super_parameters`
- ✅ تفعيل قاعدة `avoid_print` في analysis_options.yaml
- ✅ استخدام `super.key` بدلاً من `Key? key`
- ✅ تحسين البنية العامة للكود

#### 4. الملفات المحدّثة
```
functions/src/
├── updateStats.ts (محسّن + دالة recalcWeekly)
└── index.ts (تصدير recalcWeekly)

lib/features/dashboard/
├── providers/dashboard_providers.dart (تحديث فوري بدون print)
├── presentation/dashboard_screen.dart (super parameters)
└── widgets/stat_card_widget.dart (super parameters)

analysis_options.yaml (تفعيل avoid_print)
```

## استخدام دالة recalcWeekly

### من Flutter App:
```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<void> refreshWeeklyOrders() async {
  try {
    final callable = FirebaseFunctions.instance.httpsCallable('recalcWeekly');
    final result = await callable.call();
    
    print('Success: ${result.data['message']}');
    print('Weekly Orders: ${result.data['weeklyOrders']}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### من Firebase Console:
```javascript
firebase functions:shell

> recalcWeekly({}, {auth: {uid: 'admin-uid', token: {role: 'admin'}}})
```

## نشر التحديثات (Deployment)

### 1. نشر Cloud Functions:
```bash
cd functions
npm install
npm run build
firebase deploy --only functions
```

### 2. تشغيل التطبيق:
```bash
flutter pub get
flutter run
```

## البنية التقنية

### Cloud Functions
- **Firebase Functions v2**
- **TypeScript**
- **Firestore Triggers**: تحديث تلقائي للإحصائيات
- **HTTPS Callable**: recalcWeekly للمديرين

### Flutter App
- **Flutter 3.x**
- **Riverpod**: إدارة الحالة
- **Cloud Firestore**: قاعدة البيانات
- **StreamProvider**: تحديثات فورية

### التدفق التلقائي للبيانات
```
User/Product/Order Change → Firestore Trigger → updateStats()
                                                       ↓
                                                 stats/main
                                                       ↓
                                            StreamProvider
                                                       ↓
                                                Dashboard UI
```

## متطلبات التشغيل

- Flutter SDK 3.0+
- Firebase CLI
- Node.js 18+
- حساب Firebase Project

## الإعداد الأولي

1. تثبيت المتطلبات:
```bash
npm install -g firebase-tools
flutter pub get
```

2. تسجيل الدخول إلى Firebase:
```bash
firebase login
```

3. تهيئة المشروع:
```bash
firebase init
```

4. نشر Functions:
```bash
cd functions
npm install
firebase deploy --only functions
```

## الصلاحيات

- **Admin**: الوصول الكامل + استدعاء recalcWeekly
- **Manager**: عرض البيانات والإحصائيات
- **User**: عرض محدود

## الأمان

- جميع Cloud Functions محمية بالمصادقة
- recalcWeekly محصورة على المديرين فقط
- Firestore Rules تحمي البيانات

## الدعم

لأي استفسارات أو مشاكل، يرجى فتح Issue في GitHub.

---

**آخر تحديث**: أكتوبر 2025
**الإصدار**: 2.0.0
