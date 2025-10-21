// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
// ✅ جديد: لـ kDebugMode
import 'package:flutter/foundation.dart';
// ✅ جديد: تفعيل App Check
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart'; // مولّد عبر flutterfire configure
import 'core/routing/app_router.dart'; // يحتوي routerProvider
import 'core/theme/app_theme.dart'; // يحتوي AppTheme.lightTheme/darkTheme

// (اختياري) timeago عربي إن كنت تستخدمه في الداشبورد
// ignore: unused_import
import 'package:timeago/timeago.dart' as timeago;
// ignore: unused_import
import 'package:timeago/timeago.dart' as timeago_ar show ArMessages;

Future<void> _initFirebaseOnce() async {
  WidgetsFlutterBinding.ensureInitialized();

  // منع إعادة التهيئة المتكرّرة (خاصة مع Hot Restart أو على الويب)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // ✅ جديد: تفعيل App Check (مهم جدًا لمنع PERMISSION_DENIED بسبب الإنفورس)
  // في التطوير: Debug Provider، وفي الإنتاج: Play Integrity
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.debug,
  );

  // (اختياري) تهيئة timeago بالعربية
  try {
    timeago.setLocaleMessages('ar', timeago_ar.ArMessages());
  } catch (_) {
    // تجاهل لو كانت مهيّأة مسبقًا
  }
}

void main() {
  runZonedGuarded(() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      // اطبع الأخطاء بدل إسقاط التطبيق عند التطوير
      FlutterError.dumpErrorToConsole(details);
    };

    await _initFirebaseOnce();

    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    // لوج أخطاء عامة (يمكن ربط Crashlytics لاحقًا)
    // debugPrint('Uncaught error: $error');
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // حسب إعدادك: اسم البروفايدر الصحيح للراوتر هو routerProvider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // 🔤 اللغة الافتراضية: العربية
      locale: const Locale('ar'),

      // 🌍 اللغات المدعومة
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],

      // 🧩 مفوّضو التعريب الرسميون من Flutter (تحلّ No MaterialLocalizations found)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // إن كان لديك AppLocalizations مخصّص أضِفه هنا بعد التأكد أنه يدعم 'ar'
        // AppLocalizations.delegate,
      ],

      // ✨ الثيمات (الأسماء الصحيحة لديك)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // 🔀 الراوتر - إصلاح المشكلة هنا
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,

      // (اختياري) فرض اتجاه RTL دائمًا لحالات خاصة
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
