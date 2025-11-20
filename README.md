# 🎉 Daily Vibes - Flutter App

## ✅ STATUS: KOMPLETT FERTIG! 🚀

Die komplette Daily Vibes App ist **einsatzbereit**!

### Was wurde erstellt:

#### ✅ Flutter Server
- Vollständiger Node.js/Express Backend
- `server.bat` - Windows Startskript  
- Lokale Datenspeicherung (JSON)
- Alle APIs implementiert
- Dependencies installiert

#### ✅ Flutter App
- **Alle Screens fertig:**
  - 📱 Welcome Screen - Einführung
  - 🔐 Auth Screen - Login/Register
  - 🏠 Home Screen - Feed & Challenge
  - 📸 Camera Screen - Foto aufnehmen
  - 👥 Friends Screen - Freunde verwalten
  - ⚙️ Profile Screen - Einstellungen & Benachrichtigungen
- **Alle Models:** User, Photo, Challenge
- **Alle Services:** Auth, API
- **Dependencies:** Alle installiert

---

## 🚀 INSTALLATION & START

### Schritt 1: Server starten

```bash
cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server
server.bat
```

Der Server zeigt dann deine IP an:
```
Server erreichbar unter: http://192.168.1.100:3000
```

**📝 Notiere diese IP-Adresse!**

### Schritt 2: Server-URL in App ändern

Öffne: `lib\services\api_service.dart` (Zeile 11)

Ändere:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

Zu deiner Server-IP:
```dart
static const String baseUrl = 'http://192.168.1.100:3000/api';
```

### Schritt 3: App starten

**Variante A - Mit Flutter im PATH:**
```bash
cd C:\Users\pipot\Documents\daily_vibes_flutter
flutter run
```

**Variante B - Direkter Pfad:**
```bash
cd C:\Users\pipot\Documents\daily_vibes_flutter
C:\Users\pipot\flutter\bin\flutter.bat run
```

**Für Android APK:**
```bash
flutter build apk --release
```

Die APK findest du dann in: `build\app\outputs\flutter-apk\app-release.apk`

---

## ✨ FEATURES

### Alle Features implementiert:

#### 1. 🎯 Tägliche Challenges
- 10 verschiedene Challenges (Lächeln, Peace, Verrückt, Snack, Fensterblick, etc.)
- BeReal-Style: 2-Stunden Zeitfenster
- Live-Countdown Timer
- Zufällige Startzeit (8-22 Uhr)

#### 2. 📸 Foto-Upload
- Kamera öffnen
- Aus Galerie wählen
- Beschreibung hinzufügen
- Automatische Komprimierung
- Offline-Speicherung vorbereitet

#### 3. 👥 Freunde-System
- Freunde hinzufügen
- Freundschaftsanfragen
- Anfragen annehmen/ablehnen
- Freunde entfernen
- Freundesliste

#### 4. ❤️ Likes & Kommentare
- Fotos liken (mit Zähler)
- Kommentare schreiben
- Echtzeit-Anzeige

#### 5. 🔔 Benachrichtigungen
- Freundschaftsanfragen
- Neue Fotos
- Likes
- Kommentare
- Ungelesene Zähler

#### 6. ⚡ Echtzeit-Updates
- Auto-Refresh alle 5 Sekunden
- Pull-to-Refresh
- Live Timer

#### 7. 🎨 Design
- Gleiche Farben wie HTML (Pink/Orange Gradient)
- Dark Mode
- Material Design 3
- Smooth Animationen

---

## 📁 Projektstruktur

```
daily_vibes_flutter/
├── lib/
│   ├── main.dart                     ✅ App-Entry
│   ├── models/
│   │   ├── user.dart                 ✅
│   │   ├── photo.dart                ✅
│   │   └── challenge.dart            ✅
│   ├── services/
│   │   ├── auth_service.dart         ✅
│   │   └── api_service.dart          ✅
│   └── screens/
│       ├── welcome_screen.dart       ✅
│       ├── auth_screen.dart          ✅
│       ├── home_screen.dart          ✅
│       ├── camera_screen.dart        ✅
│       ├── friends_screen.dart       ✅
│       └── profile_screen.dart       ✅
└── pubspec.yaml                      ✅
```

---

## 🔧 Troubleshooting

### "Server nicht erreichbar"
- Stelle sicher, dass `server.bat` läuft
- Überprüfe die IP in `api_service.dart`
- Handy und PC müssen im gleichen WLAN sein

### "Flutter command not found"
```bash
# Terminal neu öffnen oder:
C:\Users\pipot\flutter\bin\flutter.bat run
```

### Camera Permission Fehler
- **Android:** Gehe zu App-Einstellungen → Berechtigungen → Kamera
- **iOS:** Überprüfe Info.plist

### Build Fehler
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📡 Server API

Alle Endpoints dokumentiert in `flutter_server/README.md`

**Basis-URL:** `http://DEINE_IP:3000/api`

**Auth:**
- `POST /auth/register` - Registrierung
- `POST /auth/login` - Login

**Challenge:**
- `GET /challenge/today` - Heutige Challenge

**Photos:**
- `POST /photos/upload` - Upload
- `GET /photos/today` - Feed
- `GET /photos/me/today` - Mein Foto
- `POST /photos/like` - Liken
- `POST /photos/comment` - Kommentieren

**Friends:**
- `GET /friends` - Liste
- `POST /friends/add` - Hinzufügen
- `POST /friends/accept` - Akzeptieren
- `POST /friends/remove` - Entfernen
- `GET /friends/requests` - Anfragen

**Notifications:**
- `GET /notifications` - Alle
- `POST /notifications/read` - Als gelesen markieren

---

## 🎯 Challenge-Beispiele

Die App wählt täglich zufällig:
- 😊 **Lächeln** - Zeige dein schönstes Lächeln!
- ✌️ **Peace** - Zeig das Peace-Zeichen!
- 🤪 **Verrückt** - Mach die verrückteste Grimasse!
- 💼 **Arbeitsplatz** - Zeig deinen Arbeitsplatz ohne aufzuräumen
- 🌅 **Morgenblick** - Das Erste nach dem Aufwachen
- 🔍 **Verloren** - Etwas, das du verlegt hast
- 🍿 **Snack-Time** - Dein aktueller Snack
- 🪟 **Fensterblick** - Foto aus deinem Fenster
- 👍 **Daumen hoch** - Alles super!
- 🙏 **Dankbar** - Zeig Dankbarkeit!

---

## 💡 Tipps

- **24/7 Server:** Lass den Server auf einem PC/Raspberry Pi laufen
- **Static IP:** Nutze eine feste IP für den Server
- **Backup:** Sichere regelmäßig den `data/` Ordner
- **Production:** Für Veröffentlichung eine echte Datenbank nutzen (MongoDB, PostgreSQL)

---

## 🚀 Production Build

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

---

**🎉 Alles fertig! Viel Spaß mit Daily Vibes! 🎉**
