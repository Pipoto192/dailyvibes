import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'auth_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? token;

  const EmailVerificationScreen({super.key, this.token});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    if (widget.token == null || widget.token!.isEmpty) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = 'Ungültiger Verifizierungslink';
      });
      return;
    }

    try {
      final api = context.read<ApiService>();
      await api.verifyEmail(widget.token!);

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message =
            'Email erfolgreich bestätigt! Du kannst dich jetzt anmelden.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B9D),
              Color(0xFFC239B3),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.error,
                          size: 80,
                          color: _isSuccess ? Colors.green : Colors.red,
                        ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        _isLoading
                            ? 'Email wird verifiziert...'
                            : _isSuccess
                                ? '✅ Erfolgreich!'
                                : '❌ Fehler',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Message
                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Button
                      if (!_isLoading)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const AuthScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B9D),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isSuccess ? 'Zur Anmeldung' : 'Zurück',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
