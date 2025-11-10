// backend/routes/purchases.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

// Create a purchase + purchase_items (transaction)
router.post('/', async (req, res) => {
  // payload: { patient_id, pharmacy_id, items: [{ item_id, quantity }] }
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const { patient_id, pharmacy_id, items } = req.body;
    const [pRes] = await conn.query(
      `INSERT INTO purchases (patient_id, pharmacy_id) VALUES (?, ?)`,
      [patient_id || null, pharmacy_id || null]
    );
    const purchaseId = pRes.insertId;

    for (const it of items) {
      const priceRow = await conn.query(`SELECT price FROM items WHERE item_id = ?`, [it.item_id]);
      const price = priceRow[0][0] ? priceRow[0][0].price : 0;
      await conn.query(
        `INSERT INTO purchase_items (purchase_id, item_id, quantity, price) VALUES (?, ?, ?, ?)`,
        [purchaseId, it.item_id, it.quantity, price]
      );
      // The after_purchase_item_insert trigger will reduce stock_qty, but if you prefer to update here:
      // await conn.query(`UPDATE items SET stock_qty = GREATEST(stock_qty - ?, 0) WHERE item_id = ?`, [it.quantity, it.item_id]);
    }

    await conn.commit();
    res.json({ message: "Purchase created", purchaseId });
  } catch (err) {
    await conn.rollback();
    console.error("Error creating purchase:", err);
    res.status(500).json({ error: "Failed to create purchase" });
  } finally {
    conn.release();
  }
});

// Get purchases for a patient
router.get('/patient/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [rows] = await pool.query(`
      SELECT pu.purchase_id, pu.purchase_date, 
        IFNULL(GROUP_CONCAT(CONCAT(i.item_name,' x', pi.quantity) SEPARATOR ', '),'') AS items,
        IFNULL(SUM(pi.quantity * pi.price),0) AS total
      FROM purchases pu
      LEFT JOIN purchase_items pi ON pu.purchase_id = pi.purchase_id
      LEFT JOIN items i ON pi.item_id = i.item_id
      WHERE pu.patient_id = ?
      GROUP BY pu.purchase_id
      ORDER BY pu.purchase_date DESC
    `, [id]);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching purchases:", err);
    res.status(500).json({ error: "Failed to fetch purchases" });
  }
});

module.exports = router;
