import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'admin_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 48),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B9D), Color(0xFFFFA07A)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B9D).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '📸',
              style: TextStyle(fontSize: 50),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6B9D), Color(0xFFFFA07A)],
          ).createShader(bounds),
          child: const Text(
            'Daily Vibes',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Teile deine Emotionen jeden Tag',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isLogin ? 'Anmelden' : 'Registrieren',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _usernameController,
              label: 'Benutzername',
              icon: Icons.person,
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'E-Mail',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              label: 'Passwort',
              icon: Icons.lock,
              obscureText: true,
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Passwort wiederholen',
                icon: Icons.lock_outline,
                obscureText: true,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      _isLogin ? 'Anmelden' : 'Account erstellen',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                  _formKey.currentState?.reset();
                });
              },
              child: Text(
                _isLogin
                    ? 'Noch kein Account? Hier registrieren'
                    : 'Bereits registriert? Hier anmelden',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6B9D)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B9D)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bitte ausfüllen';
        }
        if (!_isLogin && label == 'E-Mail' && !value.contains('@')) {
          return 'Ungültige E-Mail';
        }
        if (label == 'Passwort' && value.length < 6) {
          return 'Mindestens 6 Zeichen';
        }
        if (!_isLogin &&
            label == 'Passwort wiederholen' &&
            value != _passwordController.text) {
          return 'Passwörter stimmen nicht überein';
        }
        return null;
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = context.read<ApiService>();
      final authService = context.read<AuthService>();

      if (_isLogin) {
        final result = await apiService.login(
          _usernameController.text,
          _passwordController.text,
        );
        await authService.setAuth(
          result['token'],
          User.fromJson(result['user']),
        );

        if (mounted) {
          // Check if admin user
          final username = _usernameController.text;
          if (username == 'admin' ||
              username == 'dailyadmin' ||
              username == 'vibesadmin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        }
      } else {
        // Registration
        await apiService.register(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
        );

        // Don't auto-login after registration - show verification message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '📧 Registrierung erfolgreich!\n\n'
                'Wir haben dir eine Bestätigungs-Email an ${_emailController.text} gesendet.\n\n'
                'Bitte klicke auf den Link in der Email, um dein Konto zu aktivieren.',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 8),
            ),
          );

          // Switch to login mode
          setState(() {
            _isLogin = true;
            _passwordController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
