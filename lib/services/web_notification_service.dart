import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'api_service.dart';

class WebNotificationService {
  static Timer? _pollingTimer;
  static List<Map<String, dynamic>> _lastNotifications = [];
  static bool _isInitialized = false;

  static Future<String> requestPermission() async {
    if (!kIsWeb) return 'denied';

    try {
      debugPrint('🔔 Requesting notification permission...');

      final permission = await web.Notification.requestPermission().toDart;
      final permissionStr = permission.toDart;
      debugPrint('🔔 Permission result: $permissionStr');
      return permissionStr;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return 'denied';
    }
  }

  static String getPermissionStatus() {
    if (!kIsWeb) return 'denied';
    try {
      final permission = web.Notification.permission;
      // NotificationPermission is a JSString, convert to Dart string
      return permission.toString();
    } catch (e) {
      debugPrint('Error getting permission status: $e');
      return 'default';
    }
  }

  static Future<void> initialize(ApiService apiService) async {
    if (!kIsWeb || _isInitialized) return;

    final permission = getPermissionStatus();
    debugPrint('Current notification permission: $permission');

    if (permission == 'granted') {
      _isInitialized = true;
      startPolling(apiService);
    }
  }

  static void startPolling(ApiService apiService) {
    if (!kIsWeb) return;

    // Poll every 30 seconds for new notifications
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final result = await apiService.getNotifications();
        final notifications = result['notifications'] as List? ?? [];

        // Check for new notifications
        for (var notif in notifications) {
          if (!_lastNotifications.any((n) => n['id'] == notif['id'])) {
            // New notification - show it
            _showBrowserNotification(
              title: notif['title'] ?? 'Daily Vibes',
              body: notif['body'] ?? '',
            );
          }
        }

        _lastNotifications = List<Map<String, dynamic>>.from(notifications);
      } catch (e) {
        debugPrint('Web notification polling error: $e');
      }
    });

    debugPrint('✅ Web notification polling started');
  }

  static void _showBrowserNotification({
    required String title,
    required String body,
  }) {
    if (!kIsWeb) return;

    try {
      web.Notification(
        title,
        web.NotificationOptions(
          body: body,
          icon: 'icons/Icon-192.png',
        ),
      );
      debugPrint('🔔 Browser notification shown: $title');
    } catch (e) {
      debugPrint('Error showing browser notification: $e');
    }
  }

  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('Web notification polling stopped');
  }

  static void dispose() {
    stopPolling();
    _isInitialized = false;
  }
}
