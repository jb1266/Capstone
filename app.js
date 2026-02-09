const express = require('express');
const mysql = require('mysql');
const path = require('path');
const app = express();
const port = 3000;

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password123', // Replace with your actual password
  database: 'producev1'
});

// Serve the HTML file from the 'public' folder
app.use(express.static('public'));

// API Route: Get all produce from the DB
app.get('/api/produce', (req, res) => {
  connection.query('SELECT * FROM Produce', (err, results) => {
    if (err) return res.status(500).send(err);
    res.json(results);
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
