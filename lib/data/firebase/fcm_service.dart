import 'package:firebase_messaging/firebase_messaging.dart';

import '../../core/utils/logger.dart';
import '../../core/utils/constants.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger.info('Background message received', message.notification?.title);
}

/// FCM service for push notifications
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  static FCMService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  /// Initialize FCM
  Future<void> initialize() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        Logger.success('FCM permission granted');

        // Get FCM token
        _fcmToken = await _messaging.getToken();
        Logger.info('FCM Token', _fcmToken);

        // Subscribe to admin alerts topic
        await subscribeToAdminAlerts();

        // Set up message handlers
        _setupMessageHandlers();

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );
      } else {
        Logger.warning('FCM permission denied');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize FCM', e, stackTrace);
    }
  }

  /// Set up message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Logger.info('Foreground message received', message.notification?.title);
      _handleMessage(message);
    });

    // Message opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Logger.info('Message opened from background', message.notification?.title);
      _handleMessageOpened(message);
    });

    // Message opened from terminated state
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        Logger.info('Message opened from terminated', message.notification?.title);
        _handleMessageOpened(message);
      }
    });
  }

  /// Handle foreground message
  void _handleMessage(RemoteMessage message) {
    // Show local notification or update UI
    // Implementation depends on your notification UI strategy
  }

  /// Handle message opened
  void _handleMessageOpened(RemoteMessage message) {
    // Navigate to relevant screen based on message data
    final data = message.data;
    Logger.info('Message data', data);

    // Example: Navigate based on notification type
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'new_redemption':
          // Navigate to redemptions screen
          break;
        case 'low_stock':
          // Navigate to products screen
          break;
        default:
          break;
      }
    }
  }

  /// Subscribe to admin alerts topic
  Future<void> subscribeToAdminAlerts() async {
    try {
      await _messaging.subscribeToTopic(AppConstants.adminAlertsTopic);
      Logger.success('Subscribed to admin alerts topic');
    } catch (e) {
      Logger.error('Failed to subscribe to admin alerts', e);
    }
  }

  /// Subscribe to manager alerts topic
  Future<void> subscribeToManagerAlerts() async {
    try {
      await _messaging.subscribeToTopic(AppConstants.managerAlertsTopic);
      Logger.success('Subscribed to manager alerts topic');
    } catch (e) {
      Logger.error('Failed to subscribe to manager alerts', e);
    }
  }

  /// Unsubscribe from admin alerts topic
  Future<void> unsubscribeFromAdminAlerts() async {
    try {
      await _messaging.unsubscribeFromTopic(AppConstants.adminAlertsTopic);
      Logger.success('Unsubscribed from admin alerts topic');
    } catch (e) {
      Logger.error('Failed to unsubscribe from admin alerts', e);
    }
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Refresh FCM token
  Future<String?> refreshToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      Logger.info('FCM token refreshed', _fcmToken);
      return _fcmToken;
    } catch (e) {
      Logger.error('Failed to refresh FCM token', e);
      return null;
    }
  }
}

