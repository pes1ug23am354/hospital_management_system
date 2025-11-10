// backend/routes/patients.js
const express = require("express");
const router = express.Router();
const pool = require("../db"); // your MySQL pool connection

// ✅ Get all patients
router.get("/", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT * FROM patients ORDER BY patient_id DESC");
    res.json(rows);
  } catch (err) {
    console.error("Error fetching patients:", err);
    res.status(500).json({ message: "Error fetching patients" });
  }
});

// ✅ Add a new patient
router.post("/", async (req, res) => {
  const { name, gender, phone, dob } = req.body;
  try {
    const [result] = await pool.query(
      "INSERT INTO patients (name, gender, phone, dob) VALUES (?, ?, ?, ?)",
      [name, gender, phone || null, dob || null]
    );
    res.json({ message: "Patient added", patient_id: result.insertId });
  } catch (err) {
    console.error("Error adding patient:", err);
    res.status(500).json({ message: "Error adding patient" });
  }
});

// ✅ Delete a patient
router.delete("/:id", async (req, res) => {
  try {
    await pool.query("DELETE FROM patients WHERE patient_id = ?", [req.params.id]);
    res.json({ message: "Patient deleted" });
  } catch (err) {
    console.error("Error deleting patient:", err);
    res.status(500).json({ message: "Error deleting patient" });
  }
});

module.exports = router;
