import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/simple_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final data = await api.getNotifications();
      _notifications =
          List<Map<String, dynamic>>.from(data['notifications'] ?? []);

      // Mark all as read
      await api.markNotificationsRead();

      // Clear all system notifications
      await SimpleNotificationService.cancelAll();

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benachrichtigungen'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6B9D)))
            : _notifications.isEmpty
                ? Center(
                    child: Text(
                      'Keine Benachrichtigungen',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: const Color(0xFFFF6B9D),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) =>
                          _buildNotificationItem(_notifications[index]),
                    ),
                  ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif) {
    String message = '';
    IconData icon = Icons.notifications;
    Color iconColor = const Color(0xFFFF6B9D);

    switch (notif['type']) {
      case 'like':
        message = '${notif['from']} hat dein Foto geliked ❤️';
        icon = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        message = '${notif['from']} hat kommentiert: "${notif['text'] ?? ''}"';
        icon = Icons.comment;
        iconColor = Colors.blue;
        break;
      case 'new_photo':
        message = '${notif['from']} hat ein neues Foto gepostet';
        icon = Icons.photo_camera;
        iconColor = Colors.green;
        break;
      case 'friend_request':
        message = '${notif['from']} hat dir eine Freundschaftsanfrage gesendet';
        icon = Icons.person_add;
        break;
      default:
        message = notif['body'] ?? 'Neue Benachrichtigung';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(notif['timestamp']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) {
        return 'Gerade eben';
      } else if (diff.inHours < 1) {
        return 'vor ${diff.inMinutes}m';
      } else if (diff.inDays < 1) {
        return 'vor ${diff.inHours}h';
      } else if (diff.inDays < 7) {
        return 'vor ${diff.inDays}d';
      } else {
        return '${date.day}.${date.month}.${date.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
