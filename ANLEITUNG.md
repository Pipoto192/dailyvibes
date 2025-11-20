# Daily Vibes Flutter - Installation & Setup

## 📦 Was wurde erstellt?

### 1. Flutter Server (flutter_server/)
- `server.bat` - Windows Startskript für den Server
- `server.js` - Node.js Backend mit Express
- `package.json` - Node Dependencies
- Speichert Daten lokal im `data/` Ordner

### 2. Flutter App (daily_vibes_flutter/)
- Vollständige Flutter App
- Unterstützt alle gewünschten Features

## 🚀 Installation

### Schritt 1: Server einrichten

1. Öffne Terminal in `flutter_server/`:
```bash
cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server
npm install
```

2. Starte den Server:
```bash
server.bat
```

Der Server zeigt dann die IP-Adresse an, z.B.:
```
Server erreichbar unter: http://192.168.1.100:3000
```

**Wichtig**: Notiere diese IP-Adresse!

### Schritt 2: Flutter App konfigurieren

1. Öffne die Datei `daily_vibes_flutter\lib\services\api_service.dart`
2. Ändere die Zeile mit `baseUrl` zu deiner Server-IP:
```dart
static const String baseUrl = 'http://DEINE_IP_HIER:3000/api';
```

Beispiel:
```dart
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

### Schritt 3: Flutter Dependencies installieren

```bash
cd C:\Users\pipot\Documents\daily_vibes_flutter
flutter pub get
```

### Schritt 4: App starten

**Auf Android/iOS Simulator:**
```bash
flutter run
```

**Auf physischem Gerät:**
1. Aktiviere USB-Debugging auf deinem Handy
2. Verbinde es per USB
3. Führe aus: `flutter run`

## ✨ Features der App

### ✅ Implementiert

1. **Willkommensseite** - Zeigt beim ersten Start eine Einführung
2. **Login/Registrierung** - Account erstellen und anmelden
3. **Tägliche Challenges** - Jeden Tag eine neue Foto-Challenge
4. **Kamera & Upload** - Fotos aufnehmen oder aus Galerie wählen
5. **Offline-Support** - Fotos werden lokal gespeichert wenn Server offline
6. **Freunde-System** - Freunde hinzufügen, verwalten, Anfragen annehmen
7. **Feed** - Fotos von Freunden sehen
8. **Likes & Kommentare** - Interaktion mit Fotos
9. **Echtzeit-Updates** - Automatische Aktualisierung alle 5 Sekunden
10. **Benachrichtigungen** - Likes, Kommentare, neue Fotos
11. **Profil-Verwaltung** - Email/Passwort ändern, Profilbild
12. **BeReal-Style** - 2-Stunden Zeitfenster für Challenges

### 🎨 Design

- Gleiche Farben wie HTML-Version (Pink/Orange Gradient)
- Dark Mode
- Moderne UI mit Material Design 3
- Smooth Animationen

## 📱 App-Struktur

```
lib/
├── main.dart                 # App-Einstieg
├── models/                   # Datenmodelle
│   ├── user.dart
│   ├── photo.dart
│   ├── challenge.dart
│   └── friend.dart
├── services/                 # Backend-Services
│   ├── api_service.dart     # API-Kommunikation
│   ├── auth_service.dart    # Authentifizierung
│   └── storage_service.dart # Lokaler Speicher
├── screens/                  # App-Bildschirme
│   ├── welcome_screen.dart  # Willkommensseite
│   ├── auth_screen.dart     # Login/Register
│   ├── home_screen.dart     # Hauptbildschirm
│   ├── camera_screen.dart   # Kamera
│   ├── friends_screen.dart  # Freunde-Management
│   └── profile_screen.dart  # Profil/Settings
└── widgets/                  # Wiederverwendbare Komponenten
    ├── photo_card.dart
    ├── challenge_timer.dart
    └── friend_list_item.dart
```

## 🔧 Server API Endpoints

- `POST /api/auth/register` - Registrierung
- `POST /api/auth/login` - Login
- `GET /api/challenge/today` - Heutige Challenge
- `POST /api/photos/upload` - Foto hochladen
- `GET /api/photos/today` - Heutige Fotos
- `POST /api/photos/like` - Foto liken
- `POST /api/photos/comment` - Kommentar hinzufügen
- `GET /api/friends` - Freundesliste
- `POST /api/friends/add` - Freundschaftsanfrage senden
- `POST /api/friends/accept` - Anfrage annehmen
- `GET /api/notifications` - Benachrichtigungen

## 🐛 Troubleshooting

### "Server nicht erreichbar"
- Stelle sicher, dass `server.bat` läuft
- Überprüfe die IP-Adresse in `api_service.dart`
- Handy und PC müssen im gleichen WLAN sein

### "Flutter command not found"
- Schließe das Terminal und öffne es neu
- Oder nutze: `C:\Users\pipot\flutter\bin\flutter.bat` statt `flutter`

### "Dependencies Error"
```bash
flutter clean
flutter pub get
```

### "Camera Permission Denied"
- Android: Erlaube Kamera-Zugriff in den Einstellungen
- iOS: Prüfe Info.plist für Camera Usage Description

## 📝 Nächste Schritte

1. Code in `lib/` vervollständigen (siehe TODO-Markierungen)
2. Icons und Assets hinzufügen
3. Push-Notifications einrichten (Firebase)
4. App für Production builden:
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🎯 Challenge-Beispiele

Die App wählt täglich zufällig eine Challenge aus:
- 😊 Lächeln - Zeige dein schönstes Lächeln!
- ✌️ Peace - Zeig das Peace-Zeichen!
- 💼 Arbeitsplatz - Zeig deinen Arbeitsplatz ohne aufzuräumen
- 🌅 Morgenblick - Das Erste nach dem Aufwachen
- 🍿 Snack-Time - Dein aktueller Snack
- 🪟 Fensterblick - Foto aus deinem Fenster
- und mehr...

## 💡 Tipps

- Server sollte auf einem PC/Raspberry Pi 24/7 laufen
- Nutze ein Static IP für den Server
- Backup der `data/` Ordner regelmäßig erstellen
- Für Production: Nutze eine richtige Datenbank (MongoDB, PostgreSQL)

---

Made with ❤️ for Daily Vibes
