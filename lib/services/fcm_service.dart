import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'simple_notification_service.dart';

/// Firebase Cloud Messaging Service für Push Notifications
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  static String? get fcmToken => _fcmToken;

  /// Initialisiere FCM und fordere Permission an
  static Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ FCM Permission granted');

        // Get FCM token
        _fcmToken = await _messaging.getToken();
        debugPrint('📱 FCM Token: $_fcmToken');

        // Listen to token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('🔄 FCM Token refreshed: $newToken');
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        debugPrint('✅ FCM initialized');
      } else {
        debugPrint('❌ FCM Permission denied');
      }
    } catch (e) {
      debugPrint('❌ FCM initialization error: $e');
    }
  }

  /// Handle messages when app is in foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      await SimpleNotificationService.showNotification(
        title: message.notification!.title ?? 'Daily Vibes',
        body: message.notification!.body ?? '',
      );
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📨 Background message: ${message.notification?.title}');

  if (message.notification != null) {
    await SimpleNotificationService.showNotification(
      title: message.notification!.title ?? 'Daily Vibes',
      body: message.notification!.body ?? '',
    );
  }
}
