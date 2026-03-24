const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const db = require('./database');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Set EJS as templating engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Routes
app.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM students ORDER BY id DESC');
        res.render('index', { students: rows });
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
});

app.post('/add', async (req, res) => {
    const { name, email, course } = req.body;
    try {
        await db.query('INSERT INTO students (name, email, course) VALUES (?, ?, ?)', [name, email, course]);
        res.redirect('/');
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
});

app.post('/delete/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM students WHERE id = ?', [id]);
        res.redirect('/');
    } catch (err) {
        console.error(err);
        res.status(500).send('Server Error');
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
