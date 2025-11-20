# 🚀 Quick Start - Von überall auf die App zugreifen

## Schritt 1: Ngrok herunterladen (5 Minuten)

1. Gehe zu: https://ngrok.com/download
2. Download für Windows
3. Entpacke die `ngrok.exe` nach `C:\ngrok\`

## Schritt 2: Server & Ngrok starten

**Terminal 1 - Server:**
```powershell
cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server
node server.js
```

**Terminal 2 - Ngrok:**
```powershell
cd C:\ngrok
.\ngrok http 3000
```

**Du siehst jetzt so etwas:**
```
Forwarding   https://abc123-def.ngrok-free.app -> http://localhost:3000
```

## Schritt 3: URL in App eintragen

1. **Kopiere die ngrok URL** (z.B. `https://abc123-def.ngrok-free.app`)

2. **Öffne:** `lib/config/app_config.dart`

3. **Ändere die Zeile:**
   ```dart
   // VON:
   static const String apiBaseUrl = 'http://192.168.178.84:3000/api';
   
   // ZU:
   static const String apiBaseUrl = 'https://abc123-def.ngrok-free.app/api';
   ```

## Schritt 4: App starten

**Für Web (Chrome):**
```powershell
cd C:\Users\pipot\Documents\daily_vibes_flutter
flutter run -d chrome
```

**Für Android Handy:**
```powershell
flutter run
```

**Für iOS (auf Mac):**
```powershell
flutter run -d iphone
```

## ✅ Fertig!

Jetzt kannst du:
- 📱 Die App auf jedem Gerät öffnen (auch iPhone!)
- 🌍 Von überall zugreifen (auch außerhalb deines WLANs)
- 👥 Mit Freunden testen

## ⚠️ Wichtig:

- Ngrok URL ändert sich bei jedem Neustart (kostenlose Version)
- Dann musst du die URL in `app_config.dart` neu eintragen
- Server muss laufen solange du die App nutzt

## 💡 Tipp:

Für dauerhaften Zugriff (URL bleibt gleich):
- Ngrok Pro Account ($8/Monat) mit fester URL
- Oder Server auf Heroku/Railway deployen (kostenlos)
