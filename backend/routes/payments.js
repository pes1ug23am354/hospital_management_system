// backend/routes/payments.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

// 1) List payments with helpful info
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT 
        pay.payment_id,
        pay.bill_date,
        pay.amount,
        pay.balance_due,
        pay.mode,
        pay.remarks,
        pay.patient_id,
        p.name AS patient_name,
        t.record_id AS treatment_id,
        t.diagnosis,
        d.name AS doctor_name,
        pay.purchase_id,
        IFNULL((SELECT GROUP_CONCAT(CONCAT(i.item_name,' x', pi.quantity) SEPARATOR ', ')
                FROM purchase_items pi JOIN items i ON pi.item_id = i.item_id
                WHERE pi.purchase_id = pay.purchase_id), '') AS purchase_items
      FROM payments pay
      LEFT JOIN patients p ON pay.patient_id = p.patient_id
      LEFT JOIN treatment_records t ON pay.treatment_id = t.record_id
      LEFT JOIN doctors d ON t.doctor_id = d.doctor_id
      ORDER BY pay.bill_date DESC
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching payments:", err);
    res.status(500).json({ error: "Failed to fetch payments" });
  }
});

// 2) Summary per patient (treatment & pharmacy totals and paid amounts)
router.get('/summary', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        p.patient_id,
        p.name as patient_name,
        COALESCE((SELECT SUM(fees) FROM treatment_records tr WHERE tr.patient_id = p.patient_id),0) AS treatment_total,
        COALESCE((SELECT SUM(amount_paid) FROM treatment_records tr WHERE tr.patient_id = p.patient_id),0) AS treatment_paid,
        COALESCE((SELECT SUM(pi.quantity * it.price) FROM purchases pu
                 JOIN purchase_items pi ON pu.purchase_id = pi.purchase_id
                 JOIN items it ON pi.item_id = it.item_id
                 WHERE pu.patient_id = p.patient_id),0) AS pharmacy_total,
        COALESCE((SELECT SUM(amount) FROM payments pay WHERE pay.patient_id = p.patient_id AND pay.treatment_id IS NOT NULL),0) AS treatment_payments_sum,
        COALESCE((SELECT SUM(amount) FROM payments pay WHERE pay.patient_id = p.patient_id AND pay.purchase_id IS NOT NULL),0) AS pharmacy_payments_sum
      FROM patients p
      ORDER BY p.name
    `);
    // Add computed balances in JS for clarity
    const computed = rows.map(r => ({
      ...r,
      treatment_balance: Number(r.treatment_total || 0) - Number(r.treatment_paid || 0),
      pharmacy_balance: Number(r.pharmacy_total || 0) - Number(r.pharmacy_payments_sum || 0),
      total_due: (Number(r.treatment_total||0) + Number(r.pharmacy_total||0)) - ((Number(r.treatment_paid||0) + Number(r.pharmacy_payments_sum||0)))
    }));
    res.json(computed);
  } catch (err) {
    console.error("Error fetching summary:", err);
    res.status(500).json({ error: "Failed to fetch summary" });
  }
});

// 3) Add a payment (treatment_id OR purchase_id OR generic)
router.post('/', async (req, res) => {
  try {
    const { patient_id, treatment_id, purchase_id, amount, mode, remarks } = req.body;
    const [result] = await pool.query(
      `INSERT INTO payments (patient_id, treatment_id, purchase_id, amount, mode, remarks) VALUES (?, ?, ?, ?, ?, ?)`,
      [patient_id || null, treatment_id || null, purchase_id || null, amount || 0, mode || 'Cash', remarks || null]
    );
    res.json({ message: "Payment recorded", id: result.insertId });
  } catch (err) {
    console.error("Error adding payment:", err);
    res.status(500).json({ error: "Failed to add payment" });
  }
});

// 4) Delete payment (will invoke trigger to adjust treatment.amount_paid)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query(`DELETE FROM payments WHERE payment_id = ?`, [id]);
    res.json({ message: "Deleted payment" });
  } catch (err) {
    console.error("Error deleting payment:", err);
    res.status(500).json({ error: "Failed to delete payment" });
  }
});

module.exports = router;
