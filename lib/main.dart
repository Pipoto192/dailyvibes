import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui' as ui;
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/memory_calendar_screen.dart';
import 'screens/email_verification_screen.dart';
import 'l10n/app_localizations.dart';

import 'services/simple_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/background_notification_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize both German and English locale for date formatting
  await initializeDateFormatting('de_DE', null);
  await initializeDateFormatting('en_US', null);

  final prefs = await SharedPreferences.getInstance();
  final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

  // Only initialize mobile-specific features
  if (!kIsWeb) {
    // Mobile-only initialization will be handled by platform-specific code
    try {
      await SimpleNotificationService.initialize();
      await BackgroundNotificationService.registerPeriodicTask();
    } catch (e) {
      debugPrint('Mobile services initialization skipped: $e');
    }
  }

  runApp(DailyVibesApp(hasSeenWelcome: hasSeenWelcome));
}

class DailyVibesApp extends StatelessWidget {
  final bool hasSeenWelcome;

  const DailyVibesApp({super.key, required this.hasSeenWelcome});

  @override
  Widget build(BuildContext context) {
    // Detect locale based on system language
    // Default to German for German-speaking countries, English for others
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final isGerman = systemLocale.languageCode == 'de' ||
        systemLocale.countryCode == 'DE' ||
        systemLocale.countryCode == 'AT' ||
        systemLocale.countryCode == 'CH';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ProxyProvider<AuthService, ApiService>(
          update: (_, auth, __) => ApiService(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Daily Vibes',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('de', ''),
        ],
        locale: isGerman ? const Locale('de') : const Locale('en'),
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF6B9D),
            secondary: Color(0xFFFFA07A),
            surface: Color(0xFF1A1A1A),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1A1A),
            elevation: 0,
          ),
        ),
        routes: {
          '/memory-calendar': (context) => const MemoryCalendarScreen(),
        },
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            // Check if this is an email verification link
            final uri = Uri.base;
            if (uri.path.contains('verify-email') ||
                uri.queryParameters.containsKey('token')) {
              final token = uri.queryParameters['token'];
              return EmailVerificationScreen(token: token);
            }

            // Warte bis Auth geladen ist
            if (!auth.isInitialized) {
              return const Scaffold(
                backgroundColor: Color(0xFF0A0A0A),
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF6B9D),
                  ),
                ),
              );
            }

            if (!hasSeenWelcome) {
              return const WelcomeScreen();
            }

            if (auth.isAuthenticated) {
              return const HomeScreen();
            }

            return const AuthScreen();
          },
        ),
      ),
    );
  }
}

