# Push-Benachrichtigungen für Daily Vibes

## ⚠️ Wichtig: Firebase Setup erforderlich!

Die Push-Benachrichtigungen sind vorbereitet, aber **noch nicht vollständig funktionsfähig**. 
Du musst Firebase manuell einrichten.

## 🔧 Setup-Schritte

### 1. Firebase Projekt erstellen

1. Gehe zu [Firebase Console](https://console.firebase.google.com/)
2. Klicke auf "Projekt hinzufügen"
3. Nenne es "Daily Vibes" oder wie du möchtest
4. Folge den Anweisungen

### 2. Android App hinzufügen

1. Klicke auf das Android-Symbol
2. Package Name: `com.example.daily_vibes_flutter` (oder wie in `android/app/build.gradle`)
3. App-Spitzname: "Daily Vibes"
4. Lade `google-services.json` herunter
5. **Kopiere die Datei nach:** `android/app/google-services.json`

### 3. Firebase Konfiguration

Füge in `android/build.gradle` hinzu (sollte schon da sein):
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Füge in `android/app/build.gradle` am Ende hinzu:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4. Flutter Dependencies installieren

```bash
flutter pub get
```

### 5. Notification Service aktivieren

In `lib/main.dart` die Benachrichtigungen aktivieren:

```dart
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Notification Service initialisieren
  await NotificationService().initialize();
  
  runApp(const MyApp());
}
```

### 6. Server-Integration (Optional)

Wenn du FCM Tokens an deinen Server senden möchtest:

```dart
// In notification_service.dart bei onTokenRefresh:
Future<void> _sendTokenToServer(String token) async {
  await ApiService().updateFcmToken(token);
}
```

Und im `api_service.dart`:
```dart
Future<void> updateFcmToken(String token) async {
  await http.post(
    Uri.parse('$baseUrl/profile/fcm-token'),
    headers: _headers,
    body: jsonEncode({'fcmToken': token}),
  );
}
```

## 📱 Wie es funktioniert

### Lokale Benachrichtigungen (ohne Firebase)
- Werden direkt auf dem Gerät erstellt
- Funktionieren auch ohne Internet
- Können für In-App Events genutzt werden

### Push-Benachrichtigungen (mit Firebase)
- Vom Server ausgelöst
- Funktionieren auch wenn App geschlossen ist
- Brauchen Firebase Setup

## 🎯 Was bereits implementiert ist

✅ NotificationService Klasse erstellt
✅ Firebase Messaging Integration vorbereitet
✅ Local Notifications vorbereitet
✅ Android Permissions hinzugefügt
✅ Foreground & Background Handler

## ❌ Was noch fehlt

- `google-services.json` Datei (musst du von Firebase holen)
- Firebase Project ID in der App
- iOS Setup (falls du iOS nutzen willst)
- Server-Code zum Senden von Push Notifications

## 🚀 Test ohne Firebase

Du kannst lokale Benachrichtigungen testen ohne Firebase:

```dart
await NotificationService().showLocalNotification(
  title: 'Neue Challenge!',
  body: '😊 Lächeln - Zeige dein schönstes Lächeln!',
);
```

## 📝 Nächste Schritte

1. **Mit Firebase:** Folge den Setup-Schritten oben
2. **Ohne Firebase:** Kommentiere Firebase-Code aus und nutze nur Local Notifications

## 🆘 Troubleshooting

### "Firebase not initialized"
→ Du hast `google-services.json` vergessen

### "Permission denied"
→ Berechtigungen in Android Settings erlauben

### Keine Notifications
→ Prüfe ob `POST_NOTIFICATIONS` Permission erteilt ist (Android 13+)

---

Made with ❤️ for Daily Vibes
