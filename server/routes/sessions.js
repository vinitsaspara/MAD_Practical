const express = require('express');
const router = express.Router();
const Session = require('../models/Session');

// POST /api/sessions — create a session
router.post('/', async (req, res) => {
  try {
    const session = new Session(req.body);
    await session.save();
    res.status(201).json(session);
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({ error: 'Session already exists.' });
    }
    res.status(400).json({ error: err.message });
  }
});

// GET /api/sessions?userId=
router.get('/', async (req, res) => {
  try {
    const { userId } = req.query;
    const query = userId
      ? { $or: [{ tutorId: userId }, { learnerId: userId }] }
      : {};
    const sessions = await Session.find(query).sort({ dateTime: 1 });
    res.json(sessions);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PATCH /api/sessions/:sessionId — update status
router.patch('/:sessionId', async (req, res) => {
  try {
    const session = await Session.findOneAndUpdate(
      { sessionId: req.params.sessionId },
      { $set: { status: req.body.status } },
      { new: true }
    );
    if (!session) return res.status(404).json({ error: 'Session not found' });
    res.json(session);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
