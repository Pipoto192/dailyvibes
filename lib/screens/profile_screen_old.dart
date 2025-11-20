import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
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
      _notifications = List<Map<String, dynamic>>.from(data['notifications']);
      _unreadCount = data['unreadCount'] ?? 0;
      
      if (_unreadCount > 0) {
        await api.markNotificationsRead();
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildUserInfo(auth),
            const SizedBox(height: 24),
            _buildNotificationsSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(auth),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(AuthService auth) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFFF6B9D),
            child: Text(
              auth.user?.username[0].toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            auth.user?.username ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.user?.email ?? 'user@example.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Benachrichtigungen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B9D)))
              : _notifications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Keine Benachrichtigungen',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: _notifications
                          .take(10)
                          .map(_buildNotificationItem)
                          .toList(),
                    ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif) {
    String message = '';
    IconData icon = Icons.notifications;
    Color iconColor = const Color(0xFFFF6B9D);

    switch (notif['type']) {
      case 'friend_request':
        message = '${notif['from']} hat dir eine Freundschaftsanfrage gesendet';
        icon = Icons.person_add;
        break;
      case 'like':
        message = '${notif['from']} hat dein Foto geliked ❤️';
        icon = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        message = '${notif['from']} hat dein Foto kommentiert: "${notif['text']}"';
        icon = Icons.comment;
        iconColor = Colors.blue;
        break;
      case 'new_photo':
        message = '${notif['from']} hat ein neues Foto gepostet (${notif['challenge']})';
        icon = Icons.photo_camera;
        iconColor = Colors.green;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (notif['read'] ?? true)
            ? Colors.transparent
            : const Color(0xFFFF6B9D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (notif['read'] ?? true)
              ? Colors.transparent
              : const Color(0xFFFF6B9D).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
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

  String _formatTimestamp(String timestamp) {
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
  }

  Widget _buildSettingsSection(AuthService auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Einstellungen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          icon: Icons.email,
          title: 'E-Mail ändern',
          subtitle: auth.user?.email ?? '',
          onTap: _showChangeEmailDialog,
        ),
        _buildSettingTile(
          icon: Icons.lock,
          title: 'Passwort ändern',
          subtitle: '••••••••',
          onTap: _showChangePasswordDialog,
        ),
        _buildSettingTile(
          icon: Icons.info,
          title: 'Über Daily Vibes',
          subtitle: 'Version 1.0.0',
          onTap: _showAboutDialog,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Abmelden'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFF6B9D)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        tileColor: Colors.white.withOpacity(0.05),
        onTap: onTap,
      ),
    );
  }

  void _showChangeEmailDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature kommt bald! 🚀'),
        backgroundColor: Color(0xFFFF6B9D),
      ),
    );
  }

  void _showChangePasswordDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature kommt bald! 🚀'),
        backgroundColor: Color(0xFFFF6B9D),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFFA07A)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('📸', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            const Text('Daily Vibes'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text(
              'Eine BeReal-artige App zum Teilen von täglichen Foto-Challenges mit Freunden.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '🎯 Täglich neue Challenges\n📸 Authentische Momente\n👥 Mit Freunden verbinden\n❤️ Likes & Kommentare',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Abmelden?'),
        content: const Text('Möchtest du dich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<AuthService>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }
}
