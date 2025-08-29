# 📊 API Roblox Backend

API Node.js Express pour gérer les connexions de joueurs Roblox en temps réel.

## 🚀 Démarrage Rapide

### 1. Installer les dépendances

```bash
npm install
```

### 2. Configuration automatique avec ngrok

```bash
# Script tout-en-un qui configure ngrok + démarre le serveur
./setup-ngrok.sh
```

**OU** configuration manuelle :

**OU** configuration manuelle :

### 2a. Configurer les variables d'environnement

```bash
# Copier le fichier d'exemple
cp .env.example .env

# Éditer .env et mettre votre URL ngrok
nano .env
```

### 2b. Lancer le serveur

```bash
# En production
npm start

# En développement (avec hot reload)
npm run dev
```

Le serveur démarre sur `http://localhost:3000`

### 2c. Exposer avec ngrok

```bash
ngrok http 3000
```

## 📁 Configuration des Variables

Le fichier `.env` contient :

```bash
API_BASE_URL=https://your-ngrok-url.ngrok-free.app
PORT=3000
NODE_ENV=development
```

### 3. Exposer avec ngrok

```bash
brew install ngrok

ngrok config add-authtoken ur_token

ngrok http 3000
```

Récupérer l'URL HTTPS générée (ex: `https://abc123.ngrok-free.app`)

## 📋 Routes API

### 1. POST `/api/player-connected`

**Ce que ça fait :** Ajoute un joueur à la liste quand il se connecte

**Requête :**

```json
{
  "username": "PlayerName",
  "userId": 123456789
}
```

**Réponse :**

```json
{
  "status": "ok"
}
```

**Comment ça marche :**

- Roblox envoie le nom et l'ID du joueur
- L'API vérifie si le joueur existe déjà
- Si non, il l'ajoute à la liste `playersConnected`
- Si oui, il ignore (évite les doublons)

---

### 2. DELETE `/api/player-disconnected`

**Ce que ça fait :** Retire un joueur de la liste quand il se déconnecte

**Requête :**

```json
{
  "userId": 123456789
}
```

**Réponse :**

```json
{
  "status": "ok"
}
```

**Comment ça marche :**

- Roblox envoie juste l'ID du joueur qui part
- L'API cherche le joueur dans la liste
- Il le supprime s'il le trouve
- Retourne toujours "ok" même si le joueur n'existait pas

---

### 3. GET `/api/players`

**Ce que ça fait :** Récupère la liste de tous les joueurs connectés

**Réponse :**

```json
[
  { "username": "Player1", "userId": 123 },
  { "username": "Player2", "userId": 456 }
]
```

**Comment ça marche :**

- Pas besoin d'envoyer de données
- Retourne directement la liste `playersConnected[]`
- Mis à jour en temps réel

## 🔗 Configuration Roblox

### Automatique

Le script `setup-ngrok.sh` met à jour automatiquement :

- Le fichier `.env` du backend
- Le fichier `init.server.luau` de Roblox

### Manuelle

```bash
# Script interactif pour mettre à jour l'URL
./update-url.sh
```

**OU** édition manuelle dans `src/server/init.server.luau` :

```lua
BASE_URL = "https://VOTRE-URL-NGROK.ngrok-free.app"
```

## 🔄 Migration Python → Node.js

✅ **Terminé :**

- ✅ Code FastAPI converti en Express.js
- ✅ Routes API identiques (`/api/player-connected`, `/api/player-disconnected`, `/api/players`)
- ✅ Même format de données JSON
- ✅ CORS configuré
- ✅ Gestion d'erreurs identique

**Prochaines étapes :**

1. Démarrer le serveur Node.js : `npm start`
2. Exposer avec ngrok : `ngrok http 3000`
3. Mettre à jour l'URL dans `init.server.luau`

## 🧪 Test des Routes

```bash
# Tester connexion
curl -X POST https://votre-url.ngrok-free.app/api/player-connected \
  -H "Content-Type: application/json" \
  -d '{"username":"TestPlayer","userId":123}'

# Voir la liste
curl https://votre-url.ngrok-free.app/api/players

# Tester déconnexion
curl -X DELETE https://votre-url.ngrok-free.app/api/player-disconnected \
  -H "Content-Type: application/json" \
  -d '{"userId":123}'
```

## 🛠️ Scripts de Développement

### Configuration Automatique (Recommandé)

```bash
# Script qui fait tout : ngrok + config + serveur
./setup-ngrok.sh
```

### Scripts Individuels

```bash
# Serveur uniquement
npm start

# Serveur avec hot reload
npm run dev

# ngrok uniquement (serveur doit tourner)
npm run ngrok
```

## 📋 Structure des Fichiers

```
backend-roblox/
├── .env                 # Variables d'environnement (URL ngrok, port, etc.)
├── .env.example         # Exemple de configuration
├── main.js              # Serveur Express avec dotenv
├── package.json         # Dépendances Node.js
├── setup-ngrok.sh       # Script automatique ngrok + serveur
├── update-url.sh        # Script pour mettre à jour l'URL API
└── README.md            # Documentation
```

**Fichiers Roblox modifiés :**

- `src/server/init.server.luau` : Configuration API intégrée
- `src/shared/Config.luau` : Module optionnel (non utilisé actuellement)

## ✨ Avantages de cette Configuration

### Variables d'Environnement

- ✅ URL ngrok centralisée dans `.env`
- ✅ Port configurable
- ✅ Pas de hardcoding dans le code
- ✅ Fichier `.env` dans `.gitignore` (sécurité)

### Scripts Automatisés

- ✅ `setup-ngrok.sh` : Configuration complète automatique
- ✅ `update-url.sh` : Mise à jour facile de l'URL
- ✅ Synchronisation backend ↔ Roblox

### Structure Modulaire

- ✅ Configuration centralisée côté Roblox
- ✅ Code plus maintenable
- ✅ Facilite les changements d'environnement
