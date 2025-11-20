import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'simple_notification_service.dart';

/// Background service to check for notifications periodically
class BackgroundNotificationService {
  static const String taskName = "checkNotifications";
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// Register periodic background task (runs every 15 minutes)
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  /// Check for new notifications in background
  static Future<void> checkNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final notifications = data['data']['notifications'] as List? ?? [];
        final unreadCount = data['data']['unreadCount'] ?? 0;

        if (unreadCount > 0) {
          // Get last notification
          if (notifications.isNotEmpty) {
            final lastNotif = notifications.first;
            await SimpleNotificationService.showNotification(
              title: lastNotif['title'] ?? 'Daily Vibes',
              body: lastNotif['body'] ?? 'Neue Benachrichtigung',
            );
          }
        }
      }
    } catch (e) {
      print('Background notification check error: $e');
    }
  }
}

/// Top-level callback dispatcher for Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == BackgroundNotificationService.taskName) {
      await BackgroundNotificationService.checkNotifications();
    }
    return Future.value(true);
  });
}
