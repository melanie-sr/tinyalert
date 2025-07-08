require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

let playersConnected = [];

app.use(cors({
    origin: "*",
    credentials: true,
    methods: ["GET", "POST", "DELETE"],
    allowedHeaders: ["*"]
}));

app.use(express.json());

// Route POST pour la connexion d'un joueur
app.post('/api/player-connected', (req, res) => {
    const { username, userId } = req.body;

    if (!username || !userId) {
        return res.status(400).json({
            status: "error",
            detail: "username ou userId manquant"
        });
    }

    const already = playersConnected.some(p => p.userId === userId);
    if (!already) {
        playersConnected.push({ username, userId });
        console.log(` ${username} connecté`);
    }
    
    res.json({ status: "ok" });
});

// Route DELETE pour la déconnexion d'un joueur
app.delete('/api/player-disconnected', (req, res) => {
    const { userId } = req.body;

    if (!userId) {
        return res.status(400).json({
            status: "error",
            detail: "userId manquant"
        });
    }

    const before = playersConnected.length;
    playersConnected = playersConnected.filter(p => p.userId !== userId);
    const after = playersConnected.length;

    if (before !== after) {
        console.log(` Joueur ${userId} déconnecté et retiré.`);
    } else {
        console.log(`ℹ Joueur ${userId} déjà retiré ou inconnu.`);
    }

    res.json({ status: "ok" });
});

// Route GET pour récupérer tous les joueurs connectés
app.get('/api/players', (req, res) => {
    res.json(playersConnected);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Serveur démarré sur http://0.0.0.0:${PORT}`);
    console.log(`URL de base : ${process.env.API_BASE_URL || 'Non configurée'}`);
    console.log(`API disponible sur:`);
    console.log(`   - POST /api/player-connected`);
    console.log(`   - DELETE /api/player-disconnected`);
    console.log(`   - GET /api/players`);
    console.log(`Mettre à jour API_BASE_URL dans .env avec votre URL ngrok`);
});
