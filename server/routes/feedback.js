const express = require('express');
const router = express.Router();
const Feedback = require('../models/Feedback');
const User = require('../models/User');

// POST /api/feedback — submit feedback
router.post('/', async (req, res) => {
  try {
    const feedback = new Feedback(req.body);
    await feedback.save();

    // Update tutor's average rating
    const allFeedback = await Feedback.find({ tutorId: req.body.tutorId });
    const avg = allFeedback.reduce((sum, f) => sum + f.rating, 0) / allFeedback.length;
    await User.findByIdAndUpdate(req.body.tutorId, {
      rating: Math.round(avg * 10) / 10,
      $inc: { totalSessions: 1 },
    });

    res.status(201).json(feedback);
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({ error: 'Feedback already submitted.' });
    }
    res.status(400).json({ error: err.message });
  }
});

// GET /api/feedback?tutorId=
router.get('/', async (req, res) => {
  try {
    const query = req.query.tutorId ? { tutorId: req.query.tutorId } : {};
    const feedbacks = await Feedback.find(query).sort({ createdAt: -1 });
    res.json(feedbacks);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
