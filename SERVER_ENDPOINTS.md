# Server-Endpunkte für neue Features

Diese Endpunkte müssen im Node.js Server (`server.js`) hinzugefügt werden.

## ⚠️ WICHTIG: Diese Endpunkte fehlen noch!

Die App erwartet diese Endpunkte, aber sie sind im Server noch nicht implementiert:
- `/api/profile/image` - 404 Error
- `/api/profile/email` - 404 Error  
- `/api/profile/password` - 404 Error
- `/api/profile` - 404 Error

**Ohne diese Endpunkte funktionieren Profilbild-, Email- und Passwort-Änderungen nicht!**

---

## 📝 Neue API Endpunkte

### 1. Profilbild ändern
```javascript
app.post('/api/profile/image', authenticateToken, async (req, res) => {
  try {
    const { profileImage } = req.body;
    const username = req.user.username;
    
    // User laden
    const users = loadData('users.json');
    const user = users.find(u => u.username === username);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Benutzer nicht gefunden' 
      });
    }
    
    // Profilbild aktualisieren
    user.profileImage = profileImage;
    saveData('users.json', users);
    
    res.json({
      success: true,
      message: 'Profilbild aktualisiert',
      data: { user: sanitizeUser(user) }
    });
  } catch (error) {
    console.error('Profilbild-Fehler:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

### 2. Email ändern
```javascript
app.post('/api/profile/email', authenticateToken, async (req, res) => {
  try {
    const { newEmail, password } = req.body;
    const username = req.user.username;
    
    if (!newEmail || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email und Passwort erforderlich' 
      });
    }
    
    // Email-Format prüfen
    if (!newEmail.includes('@')) {
      return res.status(400).json({ 
        success: false, 
        message: 'Ungültige Email-Adresse' 
      });
    }
    
    const users = loadData('users.json');
    const user = users.find(u => u.username === username);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Benutzer nicht gefunden' 
      });
    }
    
    // Passwort prüfen
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ 
        success: false, 
        message: 'Falsches Passwort' 
      });
    }
    
    // Prüfen ob Email schon verwendet wird
    if (users.some(u => u.email === newEmail && u.username !== username)) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email wird bereits verwendet' 
      });
    }
    
    // Email aktualisieren
    user.email = newEmail;
    saveData('users.json', users);
    
    res.json({
      success: true,
      message: 'Email aktualisiert',
      data: { user: sanitizeUser(user) }
    });
  } catch (error) {
    console.error('Email-Änderungs-Fehler:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

### 3. Passwort ändern
```javascript
app.post('/api/profile/password', authenticateToken, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const username = req.user.username;
    
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ 
        success: false, 
        message: 'Altes und neues Passwort erforderlich' 
      });
    }
    
    if (newPassword.length < 6) {
      return res.status(400).json({ 
        success: false, 
        message: 'Passwort muss mindestens 6 Zeichen lang sein' 
      });
    }
    
    const users = loadData('users.json');
    const user = users.find(u => u.username === username);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Benutzer nicht gefunden' 
      });
    }
    
    // Altes Passwort prüfen
    const validPassword = await bcrypt.compare(oldPassword, user.password);
    if (!validPassword) {
      return res.status(401).json({ 
        success: false, 
        message: 'Falsches altes Passwort' 
      });
    }
    
    // Neues Passwort hashen und speichern
    user.password = await bcrypt.hash(newPassword, 10);
    saveData('users.json', users);
    
    res.json({
      success: true,
      message: 'Passwort aktualisiert'
    });
  } catch (error) {
    console.error('Passwort-Änderungs-Fehler:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

### 4. Profil laden
```javascript
app.get('/api/profile', authenticateToken, (req, res) => {
  try {
    const username = req.user.username;
    const users = loadData('users.json');
    const user = users.find(u => u.username === username);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Benutzer nicht gefunden' 
      });
    }
    
    res.json({
      success: true,
      data: { user: sanitizeUser(user) }
    });
  } catch (error) {
    console.error('Profil-Lade-Fehler:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

### 5. Helper-Funktion: sanitizeUser
```javascript
// Diese Funktion sollte oben im Server hinzugefügt werden (nach den imports)
function sanitizeUser(user) {
  return {
    username: user.username,
    email: user.email,
    profileImage: user.profileImage || null,
    createdAt: user.createdAt
  };
}
```

### 6. Registrierung erweitern
```javascript
// Im Register-Endpunkt (POST /api/auth/register):
// Ändere diese Zeile:
const newUser = {
  username,
  email,
  password: hashedPassword,
  profileImage: null,  // <-- Diese Zeile hinzufügen!
  friends: [],
  pendingRequests: [],
  createdAt: new Date().toISOString()
};
```

### 7. Memories - Fotos von allen Tagen (NEU!)
```javascript
app.get('/api/photos/me/memories', authenticateToken, (req, res) => {
  try {
    const username = req.user.username;
    const limit = parseInt(req.query.limit) || 30;
    
    const photos = loadData('photos.json');
    
    // Alle Fotos des Users, sortiert nach Datum (neueste zuerst)
    const myPhotos = photos
      .filter(p => p.username === username)
      .sort((a, b) => new Date(b.date) - new Date(a.date))
      .slice(0, limit);
    
    res.json({
      success: true,
      data: { photos: myPhotos }
    });
  } catch (error) {
    console.error('Memories-Fehler:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

---

## 🔧 Installation - Schritt für Schritt

### 1. Server-Datei öffnen
```bash
notepad C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server\server.js
```

### 2. sanitizeUser Funktion hinzufügen
Füge nach den `require()` Zeilen und vor `const app = express();` ein:
```javascript
// Helper-Funktion zum Bereinigen von User-Daten
function sanitizeUser(user) {
  return {
    username: user.username,
    email: user.email,
    profileImage: user.profileImage || null,
    createdAt: user.createdAt
  };
}
```

### 3. Endpunkte hinzufügen
Füge alle 4 Endpunkte nach den bestehenden Auth-Endpunkten ein:
- `/api/profile/image`
- `/api/profile/email`
- `/api/profile/password`
- `/api/profile`

### 4. Register-Endpunkt erweitern
Suche nach `POST /api/auth/register` und füge `profileImage: null` zum `newUser` Objekt hinzu.

### 5. Server neu starten
```bash
cd C:\Users\pipot\Documents\daily_vibes_flutter\flutter_server
# Stoppe den laufenden Server (Ctrl+C)
server.bat
```

---

## 🧪 Testen

### Mit der Flutter App:
1. Öffne die App
2. Gehe zu Profil
3. Tippe auf das Kamera-Icon beim Profilbild
4. Wähle ein Bild → Sollte funktionieren!
5. Versuche Email zu ändern → Sollte funktionieren!
6. Versuche Passwort zu ändern → Sollte funktionieren!

### Mit PowerShell (optional):
```powershell
# Token von Login bekommen
$token = "DEIN_JWT_TOKEN"

# Profilbild ändern
Invoke-RestMethod -Uri "http://192.168.178.84:3000/api/profile/image" `
  -Method POST `
  -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
  -Body '{"profileImage":"data:image/png;base64,iVBORw0KG..."}'

# Email ändern
Invoke-RestMethod -Uri "http://192.168.178.84:3000/api/profile/email" `
  -Method POST `
  -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
  -Body '{"newEmail":"neu@example.com","password":"meinpasswort"}'

# Passwort ändern
Invoke-RestMethod -Uri "http://192.168.178.84:3000/api/profile/password" `
  -Method POST `
  -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
  -Body '{"oldPassword":"alt","newPassword":"neu123"}'
```

---

## ✅ Checklist

- [ ] `sanitizeUser` Funktion hinzugefügt
- [ ] `/api/profile/image` Endpunkt hinzugefügt
- [ ] `/api/profile/email` Endpunkt hinzugefügt
- [ ] `/api/profile/password` Endpunkt hinzugefügt
- [ ] `/api/profile` GET Endpunkt hinzugefügt
- [ ] `/api/photos/me/memories` GET Endpunkt hinzugefügt (NEU!)
- [ ] `profileImage: null` in Register-Endpunkt hinzugefügt
- [ ] Server neu gestartet
- [ ] Mit Flutter App getestet
- [ ] Keine 404-Fehler mehr

---

## 🐛 Fehlerbehebung

### "404 Not Found" beim Email/Passwort ändern
→ Die Endpunkte wurden noch nicht zum Server hinzugefügt!
→ Folge den Schritten oben

### "Benutzer nicht gefunden"
→ JWT Token ist ungültig oder abgelaufen
→ Neu anmelden in der App

### "profileImage ist null"
→ Normal beim ersten Mal! Wähle ein Profilbild aus

### Server startet nicht
→ Prüfe Syntax-Fehler in `server.js`
→ Alle Klammern geschlossen?
→ Kommas richtig gesetzt?

---

Made with ❤️ for Daily Vibes

### 1. Profilbild ändern
```javascript
app.post('/api/profile/image', authenticateToken, async (req, res) => {
  try {
    const { profileImage } = req.body;
    const username = req.user.username;
    
    // User laden
    const users = loadData('users.json');
    const user = users.find(u => u.username === username);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Benutzer nicht gefunden' 
      });
    }
    
    // Profilbild aktualisieren
    user.profileImage = profileImage;
    saveData('users.json', users);
    
    res.json({
      success: true,
      message: 'Profilbild aktualisiert',
      data: { user: sanitizeUser(user) }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

### 2. Email ändern
```javascript
app.post('/api/profile/email', authenticateToken, async (req, res) => {
  try {
    const { newEmail, password } = req.body;
    const username = req.user.username;
    
    if (!newEmail || !password) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email und Passwort erforderlich' 
      });
    }
    
    // Email-Format prüfen
    if (!newEmail.includes('@')) {
      return res.status(400).json({ 
        success: false, 
        message: 'Ungültige Email-Adresse' 
      });
    }
    
    const users = loadData('users.json');
    const user = users.find(u => u.username === username);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Benutzer nicht gefunden' 
      });
    }
    
    // Passwort prüfen
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ 
        success: false, 
        message: 'Falsches Passwort' 
      });
    }
    
    // Prüfen ob Email schon verwendet wird
    if (users.some(u => u.email === newEmail && u.username !== username)) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email wird bereits verwendet' 
      });
    }
    
    // Email aktualisieren
    user.email = newEmail;
    saveData('users.json', users);
    
    res.json({
      success: true,
      message: 'Email aktualisiert',
      data: { user: sanitizeUser(user) }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

### 3. Passwort ändern
```javascript
app.post('/api/profile/password', authenticateToken, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const username = req.user.username;
    
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ 
        success: false, 
        message: 'Altes und neues Passwort erforderlich' 
      });
    }
    
    if (newPassword.length < 6) {
      return res.status(400).json({ 
        success: false, 
        message: 'Passwort muss mindestens 6 Zeichen lang sein' 
      });
    }
    
    const users = loadData('users.json');
    const user = users.find(u => u.username === username);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Benutzer nicht gefunden' 
      });
    }
    
    // Altes Passwort prüfen
    const validPassword = await bcrypt.compare(oldPassword, user.password);
    if (!validPassword) {
      return res.status(401).json({ 
        success: false, 
        message: 'Falsches altes Passwort' 
      });
    }
    
    // Neues Passwort hashen und speichern
    user.password = await bcrypt.hash(newPassword, 10);
    saveData('users.json', users);
    
    res.json({
      success: true,
      message: 'Passwort aktualisiert'
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

### 4. Profil laden
```javascript
app.get('/api/profile', authenticateToken, (req, res) => {
  try {
    const username = req.user.username;
    const users = loadData('users.json');
    const user = users.find(u => u.username === username);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Benutzer nicht gefunden' 
      });
    }
    
    res.json({
      success: true,
      data: { user: sanitizeUser(user) }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: 'Serverfehler' 
    });
  }
});
```

### 5. Helper-Funktion: sanitizeUser
```javascript
// Diese Funktion sollte oben im Server hinzugefügt werden
function sanitizeUser(user) {
  return {
    username: user.username,
    email: user.email,
    profileImage: user.profileImage || null,
    createdAt: user.createdAt
  };
}
```

### 6. Registrierung erweitern
```javascript
// Im Register-Endpunkt:
const newUser = {
  username,
  email,
  password: hashedPassword,
  profileImage: null,  // <-- Hinzufügen
  friends: [],
  pendingRequests: [],
  createdAt: new Date().toISOString()
};
```

## 🔧 Installation

1. Öffne `server.js` im Server-Ordner
2. Füge die Endpunkte nach den Auth-Endpunkten ein
3. Füge die `sanitizeUser` Funktion oben hinzu
4. Erweitere die Registrierung
5. Server neu starten

```bash
cd C:\Users\pipot\Documents\dailyvibes\flutter_server
server.bat
```

## 🧪 Testen

Mit PowerShell testen:
```powershell
# Token von Login bekommen
$token = "DEIN_JWT_TOKEN"

# Profilbild ändern
Invoke-RestMethod -Uri "http://localhost:3000/api/profile/image" `
  -Method POST `
  -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
  -Body '{"profileImage":"data:image/png;base64,iVBORw0KG..."}'

# Email ändern
Invoke-RestMethod -Uri "http://localhost:3000/api/profile/email" `
  -Method POST `
  -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
  -Body '{"newEmail":"neu@example.com","password":"meinpasswort"}'

# Passwort ändern
Invoke-RestMethod -Uri "http://localhost:3000/api/profile/password" `
  -Method POST `
  -Headers @{"Authorization"="Bearer $token"; "Content-Type"="application/json"} `
  -Body '{"oldPassword":"alt","newPassword":"neu123"}'
```

## ✅ Checklist

- [ ] `sanitizeUser` Funktion hinzugefügt
- [ ] `/api/profile/image` Endpunkt hinzugefügt
- [ ] `/api/profile/email` Endpunkt hinzugefügt
- [ ] `/api/profile/password` Endpunkt hinzugefügt
- [ ] `/api/profile` GET Endpunkt hinzugefügt
- [ ] `profileImage` in User-Model hinzugefügt
- [ ] Server neu gestartet
- [ ] Mit Flutter App getestet

---

Made with ❤️ for Daily Vibes
