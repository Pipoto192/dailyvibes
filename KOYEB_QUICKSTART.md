# ⚡ Koyeb Quick Start (5 Minuten)

## 1️⃣ GitHub Repository erstellen

```powershell
cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server

# Prüfen ob Git schon initialisiert ist
git status

# Falls nicht initialisiert:
git init
git add .
git commit -m "Initial server"
```

## 2️⃣ Auf GitHub hochladen

1. Gehe zu: https://github.com/new
2. Repository Name: `daily-vibes-server`
3. Privat oder Öffentlich (egal)
4. **Erstellen** klicken

Dann im Terminal:
```powershell
git remote add origin https://github.com/DEIN-USERNAME/daily-vibes-server.git
git branch -M main
git push -u origin main
```

## 3️⃣ Koyeb Account + Deploy

1. **Registrieren:** https://app.koyeb.com/auth/signup
2. **Neue App:** "Create App" klicken
3. **GitHub wählen** → Repository autorisieren
4. **Repository auswählen:** `daily-vibes-server`
5. **Einstellungen:**
   - Build: Buildpack (automatisch erkannt)
   - Port: `3000`
   - Region: Frankfurt
   - Instance: Eco (kostenlos)
6. **Deploy** klicken

⏱️ Warte 2-3 Minuten...

## 4️⃣ URL kopieren

Nach dem Deployment siehst du:
```
https://daily-vibes-server-XXXXX.koyeb.app
```

Kopiere diese URL!

## 5️⃣ In Flutter App eintragen

Öffne: `lib/config/app_config.dart`

Ändere:
```dart
static const String apiBaseUrl = 'https://daily-vibes-server-XXXXX.koyeb.app/api';
```

## 6️⃣ App testen

```powershell
cd C:\Users\pipot\Documents\daily_vibes_flutter
flutter run -d chrome
```

## ✅ Fertig!

- Server läuft 24/7
- Von jedem Gerät erreichbar
- Kostenlos
- Bei jedem `git push` automatisch neu deployed

## 🔧 Troubleshooting

**Server startet nicht?**
- Logs auf Koyeb checken
- Port 3000 ist richtig eingestellt?

**App kann nicht verbinden?**
- HTTPS URL in app_config.dart?
- `/api` am Ende der URL?

**Data geht verloren?**
- Koyeb ist ephemeral
- Nutze MongoDB Atlas für Production (siehe KOYEB_DEPLOY.md)
