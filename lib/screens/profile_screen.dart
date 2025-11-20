import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Profile is already loaded in HomeScreen, no need to reload
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
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFF6B9D),
                backgroundImage: auth.user?.profileImage != null
                    ? MemoryImage(base64Decode(auth.user!.profileImage!))
                    : null,
                child: auth.user?.profileImage == null
                    ? Text(
                        auth.user?.username[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changeProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF1A1A1A), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
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
        _buildMemoryCalendarButton(),
        _buildMemoryPrivacyToggle(),
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

  Widget _buildMemoryCalendarButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.calendar_month, color: Color(0xFFFF6B9D)),
        title: const Text('Memory-Kalender',
            style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Alle deine Memories ansehen',
          style: TextStyle(color: Colors.white.withOpacity(0.6)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        tileColor: Colors.white.withOpacity(0.05),
        onTap: () {
          Navigator.pushNamed(context, '/memory-calendar');
        },
      ),
    );
  }

  Widget _buildMemoryPrivacyToggle() {
    return FutureBuilder<bool>(
      future: context.read<ApiService>().getMemoriesPrivacy(),
      builder: (context, snapshot) {
        final isPublic = snapshot.data ?? false;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              isPublic ? Icons.public : Icons.lock,
              color: const Color(0xFFFF6B9D),
            ),
            title: const Text(
              'Memory-Sichtbarkeit',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              isPublic
                  ? 'Freunde können deine Memories sehen'
                  : 'Nur du kannst deine Memories sehen',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
            trailing: Switch(
              value: isPublic,
              activeColor: const Color(0xFFFF6B9D),
              onChanged: (value) async {
                try {
                  await context.read<ApiService>().toggleMemoriesPrivacy();
                  setState(() {}); // Rebuild to update UI
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? '🌍 Memories sind jetzt öffentlich'
                              : '🔒 Memories sind jetzt privat',
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fehler: $e')),
                    );
                  }
                }
              },
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            tileColor: Colors.white.withOpacity(0.05),
          ),
        );
      },
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

  Future<void> _changeProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      try {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        final api = context.read<ApiService>();
        final auth = context.read<AuthService>();

        await api.updateProfileImage(base64Image);

        // Profil neu laden und User aktualisieren
        final profileData = await api.getProfile();
        final updatedUser = User.fromJson(profileData);
        await auth.updateUser(updatedUser);

        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profilbild erfolgreich geändert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showChangeEmailDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('E-Mail ändern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Neue E-Mail',
                prefixIcon: Icon(Icons.email, color: Color(0xFFFF6B9D)),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Passwort bestätigen',
                prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6B9D)),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final api = context.read<ApiService>();
                final auth = context.read<AuthService>();

                await api.updateEmail(
                  emailController.text,
                  passwordController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '📧 Bestätigungs-Email gesendet!\n\n'
                        'Wir haben dir eine Email an ${emailController.text} gesendet.\n\n'
                        'Bitte bestätige deine neue Email-Adresse, indem du auf den Link klickst.',
                      ),
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 8),
                    ),
                  );

                  // Logout user since email is unverified now
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                      (route) => false,
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D)),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Passwort ändern'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Altes Passwort',
                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFFF6B9D)),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Neues Passwort',
                prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6B9D)),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Passwort wiederholen',
                prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6B9D)),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwörter stimmen nicht überein'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await context.read<ApiService>().updatePassword(
                      oldPasswordController.text,
                      newPasswordController.text,
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwort erfolgreich geändert!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D)),
            child: const Text('Speichern'),
          ),
        ],
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
              child: const Center(
                  child: Icon(Icons.camera_alt, size: 20, color: Colors.white)),
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
              'Teile deine Emotionen jeden Tag',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Eine authentische App zum Teilen von täglichen Foto-Challenges mit Freunden. Halte deine Momente fest und bleibe mit deinen Liebsten in Verbindung.',
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
