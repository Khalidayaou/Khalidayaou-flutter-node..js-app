const mysql = require('mysql2');

// Créer une connexion à la base de données
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'nodeProject',
});

// Connexion à la base de données
connection.connect((err) => {
  if (err) {
    console.error('Erreur de connexion à la base de données: ', err);
    return;
  }
  console.log('Connecté à la base de données!');
});

module.exports = connection; // Exporter la connexion
