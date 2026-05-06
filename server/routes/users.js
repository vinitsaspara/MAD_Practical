const express = require('express');
const router = express.Router();
const User = require('../models/User');

// POST /api/users — create or update user
router.post('/', async (req, res) => {
  try {
    const data = req.body;
    const user = await User.findByIdAndUpdate(
      data._id,
      { $set: data },
      { new: true, upsert: true, runValidators: true }
    );
    res.json(user);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// GET /api/users/:id
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/users — get all users
router.get('/', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
