const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM items');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/', async (req, res) => {
  const { item_name, stock_qty, price, expiry_date } = req.body;
  try {
    await pool.query(
      'INSERT INTO items (item_name, stock_qty, price, expiry_date, pharmacy_id) VALUES (?, ?, ?, ?, ?)',
      [item_name, stock_qty || 0, price || 0, expiry_date || null, 1]
    );
    res.json({ message: 'Medicine added successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM items WHERE item_id = ?', [req.params.id]);
    res.json({ message: 'Item deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
