# 🌐 Kostenloses Hosting (24/7 Online, KEIN SLEEP)

## ⭐ Empfohlung #1: Railway.app

### Warum Railway?
- ✅ **500h/Monat kostenlos** (= 24/7 für 20 Tage)
- ✅ **KEIN SLEEP MODE** (immer erreichbar)
- ✅ Super einfach: GitHub verbinden → Deploy
- ✅ Automatische HTTPS URL

### Setup (5 Minuten):

1. **GitHub Repository erstellen:**
   ```powershell
   cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server
   git init
   git add .
   git commit -m "Initial commit"
   # Erstelle Repo auf github.com und pushe:
   git remote add origin https://github.com/DEIN-USERNAME/daily-vibes-server.git
   git push -u origin main
   ```

2. **Railway Account:**
   - Gehe zu: https://railway.app
   - Login mit GitHub
   - "New Project" → "Deploy from GitHub repo"
   - Wähle dein Repository

3. **Fertig!** 
   - Railway zeigt dir die URL (z.B. `https://daily-vibes-server.up.railway.app`)
   - Kopiere die URL

4. **In Flutter App eintragen:**
   ```dart
   // lib/config/app_config.dart
   static const String apiBaseUrl = 'https://daily-vibes-server.up.railway.app/api';
   ```

---

## Alternative #1: Fly.io

### Setup:

1. **Fly CLI installieren:**
   ```powershell
   powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"
   ```

2. **Login & Deploy:**
   ```powershell
   cd flutter_server
   fly auth signup
   fly launch
   fly deploy
   ```

3. **URL kopieren** (z.B. `https://daily-vibes.fly.dev`)

---

## Alternative #2: Cyclic.sh (Speziell für Node.js)

1. **Cyclic Account:**
   - https://www.cyclic.sh
   - Login mit GitHub
   - "Link your own repo"

2. **Deploy:**
   - Wähle dein Repository
   - Cyclic erkennt automatisch Node.js
   - Deployment startet automatisch

3. **URL** wird angezeigt

---

## Alternative #3: Glitch (Am einfachsten)

1. **Glitch Projekt:**
   - https://glitch.com
   - "New Project" → "Import from GitHub"

2. **Code hochladen:**
   - Kopiere `flutter_server` Dateien
   - Glitch startet automatisch

3. **URL:** `https://dein-projekt.glitch.me`

⚠️ **Achtung:** Glitch hat manchmal kurze Sleeps (5 Minuten)

---

## 💰 Kostenloses Limit vergleichen:

| Anbieter | Sleep Mode? | Kostenlos | Limit |
|----------|-------------|-----------|-------|
| **Railway** | ❌ Nein | ✅ Ja | 500h/Monat |
| **Fly.io** | ❌ Nein | ✅ Ja | 3 Apps |
| **Cyclic** | ❌ Nein | ✅ Ja | Unlimited |
| **Glitch** | ⚠️ 5 Min | ✅ Ja | Unlimited |
| Render | ⚠️ 15 Min | ✅ Ja | Unlimited |

---

## 🎯 Meine Empfehlung:

**Nutze Railway** - einfach, schnell, kein Sleep!

### Quick Start Railway:

```powershell
# 1. Git Repository erstellen
cd flutter_server
git init
git add .
git commit -m "Initial commit"

# 2. Auf GitHub pushen (erstelle Repo auf github.com)
git remote add origin https://github.com/DEIN-USERNAME/daily-vibes-server.git
git push -u origin main

# 3. Railway.app öffnen → GitHub verbinden → Deploy
# 4. URL kopieren → app_config.dart anpassen
# 5. Fertig! 🎉
```

---

## 📱 Flutter App + Server zusammen hosten:

### Option: Vercel (für Web App) + Railway (für Server)

**Web App auf Vercel:**
```powershell
cd C:\Users\pipot\Documents\daily_vibes_flutter
flutter build web --release
cd build/web
# Upload auf vercel.com
```

**Server auf Railway** (siehe oben)

**Ergebnis:**
- Web App: `https://daily-vibes.vercel.app`
- Server: `https://daily-vibes-server.up.railway.app`
- Beide 24/7 online, kostenlos! 🚀
