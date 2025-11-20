# Email-Verifizierung Setup mit Brevo (100% Kostenlos)

## ✅ Was ist fertig:

### Backend (Server):
- ✅ Email-Verifizierung ist **PFLICHT** beim Login
- ✅ Verification Token gültig für 24 Stunden  
- ✅ Schöne HTML-Emails mit Daily Vibes Branding
- ✅ Automatischer Versand nach Registrierung
- ✅ Google OAuth komplett entfernt

### Features:
- 📧 User muss Email bestätigen bevor Login möglich ist
- ⏰ Token läuft nach 24h ab
- 🔄 User kann neuen Link anfordern
- 🎨 Professionelle Email-Templates

## 🚀 Brevo Setup (5 Minuten, Kostenlos):

### Schritt 1: Brevo Account erstellen
1. Gehe zu https://www.brevo.com/
2. Klicke auf "Sign up free"
3. Registriere dich mit deiner Email
4. **Bestätige deine Email** (wichtig!)
5. Kein Zahlungsmittel nötig!

### Schritt 2: SMTP Zugangsdaten holen
1. Nach Login: Gehe zu deinem Namen (oben rechts) → "SMTP & API"
2. Klicke auf "SMTP" Tab
3. Du siehst:
   ```
   Server: smtp-relay.brevo.com
   Port: 587
   Login: deine-email@example.com
   ```
4. Klicke auf "Create a new SMTP key"
5. Gib einen Namen ein (z.B. "DailyVibes")
6. **WICHTIG**: Kopiere den SMTP Key sofort! (wird nur einmal angezeigt)
   - Sieht so aus: `xsmtpsib-a1b2c3d4...`

### Schritt 3: Koyeb Environment Variables setzen

Gehe zu https://app.koyeb.com/ → Dein Service → Settings → Environment Variables

Füge hinzu:
```
EMAIL_HOST=smtp-relay.brevo.com
EMAIL_PORT=587
EMAIL_USER=deine-brevo-email@example.com
EMAIL_PASS=dein-smtp-key-hier
APP_URL=https://dailyvibes.vercel.app
JWT_SECRET=daily-vibes-secret-key-2024
MONGODB_URI=mongodb+srv://dailyvibes:DV2024secure!@dailyvibes.nj7bvvc.mongodb.net/dailyvibes
```

**Wichtig**: 
- `EMAIL_USER` = Die Email mit der du dich bei Brevo angemeldet hast
- `EMAIL_PASS` = Der SMTP Key von Schritt 2

### Schritt 4: Deployment

```bash
# Im flutter_server Ordner:
cd flutter_server
npm install
git add .
git commit -m "Add required email verification with Brevo"
git push
```

Koyeb deployed automatisch!

## 🧪 Testen:

### 1. Neue Registrierung:
```
1. Registriere neuen User
2. → Bekommst "Bitte bestätige deine Email"
3. → Email wird an Postfach gesendet
4. → Klicke auf "Email bestätigen" Button
5. → Erfolg! Jetzt kannst du dich einloggen
```

### 2. Login vor Email-Bestätigung:
```
1. Versuch Login ohne Email-Bestätigung
2. → Fehler: "Bitte bestätige erst deine Email-Adresse"
3. → Prüfe Postfach und bestätige
4. → Login funktioniert
```

### 3. Abgelaufener Token (nach 24h):
```
1. Warte 24 Stunden oder ändere Code zum Testen
2. → Klick auf alten Link
3. → Fehler: "Bestätigungslink ist abgelaufen"
4. → Fordere neuen Link an
```

## 📊 Brevo Limits (Kostenlos):

- ✅ **300 Emails pro Tag** kostenlos
- ✅ Kein Zahlungsmittel nötig
- ✅ Unbegrenzte Kontakte
- ✅ Email-Tracking inklusive
- ✅ Perfekt für Start-ups!

**Beispiel**: 
- 100 Registrierungen/Tag = 100 Emails
- Noch 200 Emails übrig für Benachrichtigungen etc.

## ⚙️ Wie es funktioniert:

1. **User registriert sich** → Server erstellt Account
2. **Email wird gesendet** → Mit Bestätigungslink (24h gültig)
3. **User klickt Link** → `/verify-email?token=XXX`
4. **Server verifiziert** → `emailVerified = true`
5. **Login möglich** → Nur wenn `emailVerified = true`

## 🔒 Sicherheit:

- ✅ Token = 32 Bytes Random (crypto-sicher)
- ✅ 24h Ablauf verhindert alte Links
- ✅ HTTPS für alle Email-Links
- ✅ Token wird nach Nutzung gelöscht
- ✅ Passwörter mit bcrypt gehashed

## 🎨 Email-Design:

Die Emails haben:
- 📸 Daily Vibes Logo & Branding
- 🎨 Pink-Orange Gradient
- 📱 Responsive Design
- 🔘 Großer Call-to-Action Button
- 📋 Backup-Link zum Kopieren

## ❓ FAQ:

**Q: Was wenn Email nicht ankommt?**
A: Prüfe Spam-Ordner, oder fordere neuen Link an

**Q: Kann ich mehr als 300 Emails/Tag?**
A: Ja! Brevo hat günstige Paid Plans ab €25/Monat für unbegrenzt

**Q: Muss ich Brevo verwenden?**
A: Nein, funktioniert auch mit SendGrid, Mailgun, AWS SES, etc.

**Q: Was ist mit bestehenden Usern?**
A: Die haben `emailVerified: false` und müssen Email bestätigen

## 🐛 Troubleshooting:

**Emails werden nicht gesendet:**
1. Prüfe Koyeb Logs: `console.log` Nachrichten
2. Verifiziere Email-Variablen sind gesetzt
3. Prüfe SMTP Key ist korrekt kopiert

**"Email bereits vergeben":**
- Verwende andere Email oder lösche User aus MongoDB

**"Token abgelaufen":**
- Fordere neuen Link an über `/api/auth/send-verification`

## ✅ Status Check:

Nach Deployment, teste:
```bash
# Registrierung
curl -X POST https://dein-server.koyeb.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"test123","confirmPassword":"test123"}'

# Sollte zurückgeben: emailSent: true
```

---

**Fertig? Dann:**
1. Committe Server-Änderungen
2. Setze Brevo Variables in Koyeb
3. Teste Registrierung
4. 🎉 Email-Verifizierung läuft!
