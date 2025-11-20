import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Einfacher Notification Service mit flutter_local_notifications
class SimpleNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('📱 Notification tapped: ${details.payload}');
      },
    );

    // Request permission for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    print('✅ Notifications initialisiert');
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      print('📱 Web notification (simulated): $title - $body');
      return;
    }

    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'daily_vibes_channel',
      'Daily Vibes',
      channelDescription: 'Benachrichtigungen für Daily Vibes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    print('✅ Notification gezeigt: $title');
  }

  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notifications.cancelAll();
  }
}
