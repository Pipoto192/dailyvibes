# 🚀 Daily Vibes Server auf Koyeb deployen (Kostenlos, 24/7)

## Schritt 1: Server für Deployment vorbereiten

### package.json für Koyeb erstellen:

Erstelle `flutter_server/package.json`:

```json
{
  "name": "daily-vibes-server",
  "version": "1.0.0",
  "description": "Daily Vibes Backend Server",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "node-cron": "^3.0.3"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

## Schritt 2: GitHub Repository erstellen

```powershell
cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server

# Git initialisieren
git init

# .gitignore erstellen
echo "node_modules/
data/
*.log" > .gitignore

# Dateien hinzufügen
git add .
git commit -m "Initial commit"
```

### Auf GitHub pushen:

1. Gehe zu https://github.com/new
2. Repository Name: `daily-vibes-server`
3. Erstelle das Repository
4. Dann:

```powershell
git remote add origin https://github.com/DEIN-USERNAME/daily-vibes-server.git
git branch -M main
git push -u origin main
```

## Schritt 3: Auf Koyeb deployen

1. **Account erstellen:**
   - Gehe zu: https://app.koyeb.com/auth/signup
   - Registriere dich (kostenlos)
   - Bestätige deine E-Mail

2. **GitHub verbinden:**
   - Dashboard → "Create App"
   - "GitHub" auswählen
   - Autorisiere Koyeb für GitHub
   - Wähle dein Repository: `daily-vibes-server`

3. **App konfigurieren:**
   - **Builder**: Dockerfile oder Buildpack (wähle "Buildpack")
   - **Build command**: `npm install`
   - **Run command**: `npm start`
   - **Port**: `3000`
   - **Region**: Frankfurt (Europa) oder am nächsten
   - **Instance Type**: Eco (kostenlos)

4. **Environment Variables (optional):**
   - Füge hinzu falls nötig:
     - `PORT=3000`
     - `JWT_SECRET=dein-geheimer-key`

5. **Deploy:**
   - Klicke "Deploy"
   - Warte 2-3 Minuten

## Schritt 4: URL erhalten

Nach dem Deployment zeigt Koyeb deine URL:
```
https://daily-vibes-server-DEIN-NAME.koyeb.app
```

## Schritt 5: In Flutter App eintragen

Öffne `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String apiBaseUrl = 'https://daily-vibes-server-DEIN-NAME.koyeb.app/api';
}
```

## Schritt 6: Testen

```powershell
cd C:\Users\pipot\Documents\daily_vibes_flutter
flutter run -d chrome
```

## ✅ Fertig!

Dein Server ist jetzt:
- ✅ 24/7 online
- ✅ Von überall erreichbar
- ✅ Kostenlos
- ✅ Automatische Updates bei Git Push
- ✅ HTTPS (sicher)

## 🔄 Updates deployen

Wenn du Code änderst:

```powershell
cd flutter_server
git add .
git commit -m "Update: deine Änderung"
git push
```

Koyeb deployed automatisch neu! 🚀

## 📊 Monitoring

- Logs: https://app.koyeb.com → Deine App → "Logs"
- Status: Im Dashboard sehen
- Analytics: Requests, CPU, Memory

## ⚠️ Wichtig für data/ Ordner

Koyeb ist **ephemeral** (Dateien gehen verloren bei Neustart).

### Lösung: Externe Datenbank

Für Production solltest du:
- **MongoDB Atlas** (kostenlos, 512MB)
- **Supabase** (kostenlos, PostgreSQL)
- **PlanetScale** (kostenlos, MySQL)

verwenden statt JSON-Dateien.

## 🆓 Kostenlos Limits

- **2 Apps** kostenlos
- **512MB RAM** pro App
- **2GB Disk**
- **100GB Traffic/Monat**

Mehr als genug für Daily Vibes! 🎉
