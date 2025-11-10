// backend/routes/treatments.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

// GET all treatments (with patient + doctor + paid/balance)
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT
        t.record_id,
        t.patient_id,
        p.name AS patient_name,
        t.doctor_id,
        d.name AS doctor_name,
        t.date_of_treatment AS treatment_date,
        t.diagnosis,
        t.fees,
        IFNULL(t.amount_paid,0) AS amount_paid,
        (t.fees - IFNULL(t.amount_paid,0)) AS balance
      FROM treatment_records t
      LEFT JOIN patients p ON t.patient_id = p.patient_id
      LEFT JOIN doctors d ON t.doctor_id = d.doctor_id
      ORDER BY t.record_id DESC
    `);
    res.json(rows);
  } catch (err) {
    console.error("Error fetching treatments:", err);
    res.status(500).json({ error: "Failed to fetch treatments" });
  }
});

// Add a treatment
router.post('/', async (req, res) => {
  try {
    const { patient_id, doctor_id, diagnosis, fees, amount_paid } = req.body;
    const [result] = await pool.query(
      `INSERT INTO treatment_records (patient_id, doctor_id, diagnosis, fees, amount_paid) VALUES (?, ?, ?, ?, ?)`,
      [patient_id, doctor_id || null, diagnosis, fees || 0, amount_paid || 0]
    );
    res.json({ message: "Treatment added", id: result.insertId });
  } catch (err) {
    console.error("Error adding treatment:", err);
    res.status(500).json({ error: "Failed to add treatment" });
  }
});

// Delete a treatment
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query(`DELETE FROM treatment_records WHERE record_id = ?`, [id]);
    res.json({ message: "Deleted" });
  } catch (err) {
    console.error("Error deleting treatment:", err);
    res.status(500).json({ error: "Failed to delete" });
  }
});

module.exports = router;
