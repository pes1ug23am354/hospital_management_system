const express = require("express");
const router = express.Router();
const db = require("../db"); // mysql2 pool

// Get all doctors
router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM doctors");
    res.json(rows);
  } catch (err) {
    console.error("Error fetching doctors:", err);
    res.status(500).json({ error: "Failed to fetch doctors" });
  }
});

// Add new doctor
router.post("/", async (req, res) => {
  try {
    const { name, specialization, visiting_hours, phone, department_id } = req.body;
    
    // Build query dynamically based on available columns
    // First, check what columns exist in the doctors table
    const [columns] = await db.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'doctors'
    `);
    
    const columnNames = columns.map(col => col.COLUMN_NAME);
    
    // Build the INSERT query with only existing columns
    const fields = [];
    const values = [];
    const placeholders = [];
    
    // Always include name
    fields.push('name');
    values.push(name);
    placeholders.push('?');
    
    // Add specialisation/specialization if column exists
    if (columnNames.includes('specialisation')) {
      fields.push('specialisation');
      values.push(specialization || null);
      placeholders.push('?');
    } else if (columnNames.includes('specialization')) {
      fields.push('specialization');
      values.push(specialization || null);
      placeholders.push('?');
    }
    
    // Add visiting_hours if column exists
    if (columnNames.includes('visiting_hours')) {
      fields.push('visiting_hours');
      values.push(visiting_hours || null);
      placeholders.push('?');
    }
    
    // Add phone if column exists
    if (columnNames.includes('phone')) {
      fields.push('phone');
      values.push(phone || null);
      placeholders.push('?');
    }
    
    // Add department_id if column exists
    if (columnNames.includes('department_id')) {
      fields.push('department_id');
      values.push(department_id || null);
      placeholders.push('?');
    }
    
    const query = `INSERT INTO doctors (${fields.join(', ')}) VALUES (${placeholders.join(', ')})`;
    const [result] = await db.query(query, values);
    
    res.json({ message: "Doctor added", doctorId: result.insertId });
  } catch (err) {
    console.error("Error adding doctor:", err);
    res.status(500).json({ error: "Failed to add doctor", details: err.message });
  }
});

module.exports = router;
