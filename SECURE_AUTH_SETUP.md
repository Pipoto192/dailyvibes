# Sichere Authentifizierung - Setup Guide

## ✅ Was bereits implementiert wurde:

### Backend (Server):
1. **Google OAuth Support** 
   - Endpoint: `POST /api/auth/google`
   - Akzeptiert Google ID Token
   - Erstellt automatisch User oder loggt bestehende ein

2. **Email-Bestätigung**
   - Endpoint: `POST /api/auth/send-verification`
   - Endpoint: `GET /api/auth/verify-email?token=XXX`
   - Sendet Bestätigungs-Email bei Registrierung

3. **Erweitertes User-Schema**
   - `emailVerified` (Boolean)
   - `verificationToken` (String)
   - `googleId` (String)
   - `authProvider` ('local' or 'google')
   - `password` ist jetzt optional (für Google-User)

### Frontend (Flutter):
1. **GoogleAuthService** erstellt
2. **Packages** hinzugefügt: `google_sign_in`, `sign_in_with_apple`

## 📋 Noch zu erledigen:

### 1. Google Cloud Console Setup
1. Gehe zu https://console.cloud.google.com/
2. Erstelle ein neues Projekt oder wähle ein bestehendes
3. Aktiviere "Google+ API"
4. Gehe zu "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
5. Wähle "Web application"
6. Autorisierte JavaScript-Ursprünge: `https://dailyvibes.vercel.app`
7. Autorisierte Weiterleitungs-URIs: `https://dailyvibes.vercel.app/__/auth/handler`
8. Kopiere die **Client ID**

### 2. Koyeb Environment Variables
Setze folgende Variablen in Koyeb:
```
GOOGLE_CLIENT_ID=deine-google-client-id
EMAIL_USER=deine-gmail-adresse@gmail.com
EMAIL_PASS=dein-app-passwort
APP_URL=https://dailyvibes.vercel.app
JWT_SECRET=daily-vibes-secret-key-2024
```

### 3. Gmail App-Passwort erstellen
1. Gehe zu https://myaccount.google.com/security
2. Aktiviere 2-Faktor-Authentifizierung (falls nicht aktiv)
3. Gehe zu "App-Passwörter"
4. Erstelle ein neues App-Passwort für "Mail"
5. Kopiere das 16-stellige Passwort

### 4. Flutter Web Config
Füge in `web/index.html` hinzu (vor `</head>`):
```html
<meta name="google-signin-client_id" content="DEINE-GOOGLE-CLIENT-ID.apps.googleusercontent.com">
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

### 5. Google Auth Service aktualisieren
In `lib/services/google_auth_service.dart`:
```dart
clientId: 'DEINE-GOOGLE-CLIENT-ID.apps.googleusercontent.com',
```

## 🚀 Deployment-Schritte:

1. **Dependencies installieren:**
```bash
cd flutter_server
npm install
```

2. **Flutter packages holen:**
```bash
flutter pub get
```

3. **Server committen:**
```bash
cd flutter_server
git add .
git commit -m "Add Google OAuth and email verification"
git push
```

4. **Koyeb neu deployen:**
   - Automatisch durch Git Push
   - Oder manuell: Settings → Redeploy

5. **Flutter Web bauen:**
```bash
flutter build web --release
```

6. **Vercel deployen:**
```bash
cd build/web
vercel --prod
vercel alias <neue-url> dailyvibes.vercel.app
```

## 🧪 Testing:

### Email-Bestätigung testen:
1. Registriere einen neuen User
2. Prüfe die Konsole für den Verification-Link (oder Email-Postfach)
3. Öffne den Link: `/verify-email?token=XXX`

### Google Sign-In testen:
1. Klicke auf "Mit Google anmelden"
2. Wähle deinen Google-Account
3. Sollte automatisch einloggen

## ⚠️ Wichtige Hinweise:

- **Entwicklung**: Email-Service funktioniert nur wenn `EMAIL_USER` und `EMAIL_PASS` gesetzt sind
- **Google OAuth**: Benötigt HTTPS (funktioniert nicht auf localhost für Web)
- **Client ID**: Web Client ID ≠ Android Client ID
- **Passwort**: Google-User haben kein Passwort, können sich nur mit Google einloggen

## 📝 Nächste Schritte:

Möchtest du, dass ich:
1. Den Auth-Screen UI für Google Sign-In Button erweitere?
2. Eine Email-Verification-Seite erstelle?
3. Die API-Service um Email-Verification Calls erweitere?

Antworte mit der Nummer oder "alles" für alle Schritte!
