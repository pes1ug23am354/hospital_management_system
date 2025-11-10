const express = require('express');
const router = express.Router();

// Simple authentication endpoint
// In production, you would use proper password hashing and database validation
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Default credentials (you can add more users here)
    const validUsers = {
      'admin': 'admin123',
      'doctor': 'doctor123',
      'staff': 'staff123'
    };

    if (validUsers[username] && validUsers[username] === password) {
      res.json({
        success: true,
        message: 'Login successful',
        user: username
      });
    } else {
      res.status(401).json({
        success: false,
        message: 'Invalid username or password'
      });
    }
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({
      success: false,
      message: 'Login failed'
    });
  }
});

module.exports = router;
