// backend/routes/bills.js
const express = require("express");
const pool = require("../db");
const router = express.Router();

// ✅ GET all pharmacy purchase bills only
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT 
        pu.purchase_id AS bill_id,
        p.patient_id,
        p.name AS patient_name,
        pu.purchase_date AS bill_date,
        GROUP_CONCAT(
          CONCAT(i.item_name, ' (', pi.quantity, 'x ₹', pi.price, ')') 
          SEPARATOR ', '
        ) AS items_detail,
        SUM(pi.quantity * pi.price) AS total_amount,
        COALESCE(SUM(pay.amount), 0) AS paid_amount,
        (SUM(pi.quantity * pi.price) - COALESCE(SUM(pay.amount), 0)) AS balance_due,
        MAX(pay.mode) AS payment_mode,
        MAX(pay.remarks) AS remarks
      FROM purchases pu
      INNER JOIN patients p ON pu.patient_id = p.patient_id
      LEFT JOIN purchase_items pi ON pu.purchase_id = pi.purchase_id
      LEFT JOIN items i ON pi.item_id = i.item_id
      LEFT JOIN payments pay ON pay.purchase_id = pu.purchase_id
      GROUP BY pu.purchase_id, p.patient_id, p.name, pu.purchase_date
      ORDER BY pu.purchase_date DESC
    `);

    res.json(rows);
  } catch (err) {
    console.error("Error fetching bills:", err);
    res.status(500).json({ error: "Failed to fetch bills" });
  }
});

// ✅ GET detailed purchase items for a specific purchase
router.get("/:purchaseId/items", async (req, res) => {
  try {
    const { purchaseId } = req.params;
    const [rows] = await pool.query(`
      SELECT 
        pi.purchase_item_id,
        i.item_id,
        i.item_name,
        i.brand,
        pi.quantity,
        pi.price,
        (pi.quantity * pi.price) AS total
      FROM purchase_items pi
      JOIN items i ON pi.item_id = i.item_id
      WHERE pi.purchase_id = ?
    `, [purchaseId]);
    
    res.json(rows);
  } catch (err) {
    console.error("Error fetching purchase items:", err);
    res.status(500).json({ error: "Failed to fetch purchase items" });
  }
});

// ✅ POST create a new pharmacy purchase with items
router.post("/", async (req, res) => {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    
    const { patient_id, pharmacy_id, items, mode, amount_paid, remarks } = req.body;
    
    if (!patient_id || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: "Patient ID and items are required" });
    }
    
    // Create purchase
    const [purchaseResult] = await conn.query(
      `INSERT INTO purchases (patient_id, pharmacy_id) VALUES (?, ?)`,
      [patient_id, pharmacy_id || null]
    );
    const purchaseId = purchaseResult.insertId;
    
    // Add purchase items
    for (const item of items) {
      if (!item.item_id || !item.quantity) continue;
      
      // Get item price
      const [itemRow] = await conn.query(
        `SELECT price FROM items WHERE item_id = ?`,
        [item.item_id]
      );
      const price = itemRow[0]?.price || 0;
      
      await conn.query(
        `INSERT INTO purchase_items (purchase_id, item_id, quantity, price) VALUES (?, ?, ?, ?)`,
        [purchaseId, item.item_id, item.quantity, price]
      );
    }
    
    // Calculate total
    const [totalResult] = await conn.query(
      `SELECT SUM(quantity * price) AS total FROM purchase_items WHERE purchase_id = ?`,
      [purchaseId]
    );
    const total = totalResult[0]?.total || 0;
    
    // Create payment if amount_paid is provided
    if (amount_paid && amount_paid > 0) {
      await conn.query(
        `INSERT INTO payments (patient_id, purchase_id, amount, mode, remarks) VALUES (?, ?, ?, ?, ?)`,
        [patient_id, purchaseId, parseFloat(amount_paid), mode, remarks || null]
      );
    }
    
    await conn.commit();
    res.json({ 
      message: "Purchase created successfully", 
      purchaseId,
      total 
    });
  } catch (err) {
    await conn.rollback();
    console.error("Error creating purchase:", err);
    res.status(500).json({ error: "Failed to create purchase", details: err.message });
  } finally {
    conn.release();
  }
});

// ✅ DELETE a purchase
router.delete("/:id", async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query(`DELETE FROM purchases WHERE purchase_id = ?`, [id]);
    res.json({ message: "Purchase deleted" });
  } catch (err) {
    console.error("Error deleting purchase:", err);
    res.status(500).json({ error: "Failed to delete purchase" });
  }
});

module.exports = router;
