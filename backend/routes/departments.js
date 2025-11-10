const express = require("express");
const router = express.Router();
const db = require("../db");

// ✅ Get all departments
router.get("/", async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM departments ORDER BY department_id ASC");
    res.json(rows);
  } catch (err) {
    console.error("Error fetching departments:", err);
    res.status(500).json({ error: "Failed to fetch departments" });
  }
});

module.exports = router;
