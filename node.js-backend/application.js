const express = require('express');
const bodyParser = require('body-parser');//declarih hna
const mysql = require('mysql2');
const cors = require('cors'); // declarih hna

const app = express();
app.use(cors()); // nsiti hada
app.use(bodyParser.json()); //nsiti hada
const PORT = 3000;

// Middleware pour parser les requêtes JSON
app.use(express.json());

// Configuration de la base de données
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'nodeproject',
});

// Connexion à la base de données
connection.connect((err) => {
  if (err) {
    console.error('Erreur de connexion à la base de données: ', err);
    return;
  }
  console.log('Connecté à la base de données!');
});

// Route pour ajouter un client
app.post('/addClient', (req, res) => {
  const { nom, prenom, age } = req.body;
  console.log(nom,prenom,age);

  if (!nom || !prenom || !age) {
    return res.status(400).json({ message: 'Nom, prénom et âge sont requis.' });
  }

  const query = 'INSERT INTO client (nom, prenom, age) VALUES (?, ?, ?)';
  connection.query(query, [nom, prenom, age], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur lors de l\'ajout du client.', error: err });
    }
    res.status(200).json({ message: 'Client ajouté avec succès!', id: results.insertId });
  });
});
// Route pour récupérer tous les clients
app.get('/clients', (req, res) => {
  const query = 'SELECT * FROM client';
  connection.query(query, (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur lors de la récupération des clients.', error: err });
    }
    res.status(200).json(results);
  });
});

// Route pour modifier un client
app.put('/updateClient/:id', (req, res) => {
  const { id } = req.params;
  const { nom, prenom, age } = req.body;

  if (!nom || !prenom || !age) {
    return res.status(400).json({ message: 'Nom, prénom et âge sont requis.' });
  }

  const query = 'UPDATE client SET nom = ?, prenom = ?, age = ? WHERE id = ?';
  connection.query(query, [nom, prenom, age, id], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur lors de la modification du client.', error: err });
    }
    res.status(200).json({ message: 'Client modifié avec succès!' });
  });
});

// Route pour supprimer un client
app.delete('/deleteClient/:id', (req, res) => {
  const { id } = req.params;

  const query = 'DELETE FROM client WHERE id = ?';
  connection.query(query, [id], (err, results) => {
    if (err) {
      return res.status(500).json({ message: 'Erreur lors de la suppression du client.', error: err });
    }
    res.status(200).json({ message: 'Client supprimé avec succès!' });
  });
});
// Démarrer le serveur
app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});
