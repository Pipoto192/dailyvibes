# Web App Setup - Daily Vibes

## 1. Server von außen erreichbar machen

### Option A: Ngrok (Einfachste Lösung - Kostenlos)

1. **Ngrok installieren:**
   - Download: https://ngrok.com/download
   - Entpacken nach `C:\ngrok\`

2. **Server mit Ngrok starten:**
   ```powershell
   # Terminal 1 - Server starten
   cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server
   node server.js
   
   # Terminal 2 - Ngrok starten
   cd C:\ngrok
   .\ngrok http 3000
   ```

3. **Ngrok URL kopieren:**
   - Kopiere die URL (z.B. `https://abc123.ngrok-free.app`)
   - Öffne `lib/services/api_service.dart`
   - Ändere `baseUrl` zu: `https://abc123.ngrok-free.app/api`

### Option B: Router Port Forwarding (Dauerhaft)

1. **Router konfigurieren:**
   - Öffne Router-Admin (meist `192.168.178.1`)
   - Port Forwarding einrichten: Port 3000 → Dein PC (192.168.178.84)
   
2. **Öffentliche IP finden:**
   - Gehe zu: https://www.whatismyip.com/
   - Kopiere deine IP (z.B. `85.123.45.67`)
   
3. **URL anpassen:**
   - Ändere `baseUrl` zu: `http://85.123.45.67:3000/api`

### Option C: Cloudflare Tunnel (Professionell)

1. **Cloudflare installieren:**
   ```powershell
   winget install Cloudflare.cloudflared
   ```

2. **Tunnel starten:**
   ```powershell
   cloudflared tunnel --url http://localhost:3000
   ```

## 2. Web App bauen und deployen

### Lokales Testing:

```powershell
cd C:\Users\pipot\Documents\daily_vibes_flutter
flutter run -d chrome
```

### Production Build:

```powershell
flutter build web --release
```

Die fertige App ist in `build/web/` - Hochladen auf:
- **GitHub Pages** (kostenlos)
- **Firebase Hosting** (kostenlos)
- **Vercel** (kostenlos)
- **Netlify** (kostenlos)

## 3. Schnellstart mit Ngrok (Empfohlen):

```powershell
# Terminal 1
cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server
node server.js

# Terminal 2
C:\ngrok\ngrok http 3000

# Terminal 3
cd C:\Users\pipot\Documents\daily_vibes_flutter
# WICHTIG: Erst ngrok URL in api_service.dart eintragen!
flutter run -d chrome
```

## 4. Web-Limitierungen

⚠️ Im Web funktionieren NICHT:
- Background Notifications (nur in-app)
- WorkManager (nur Android/iOS)
- Automatische Kamera-Öffnung

✅ Im Web funktionieren:
- Login/Registrierung
- Fotos hochladen (via File Picker)
- Feed anzeigen
- Likes & Kommentare
- Freunde hinzufügen
- Notifications (in-app, keine Push)

## 5. CORS auf Server aktivieren

Die `server.js` hat bereits CORS aktiviert - sollte funktionieren!
