const express = require("express");
const router = express.Router();
const User = require("../models/User");

// GET /api/tutors?subject=&skillLevel=&minRating=
router.get("/", async (req, res) => {
  try {
    const { subject, skillLevel, minRating } = req.query;
    const query = { role: { $in: ["tutor", "both"] } };

    if (subject) {
      query.subjects = { $elemMatch: { $regex: new RegExp(subject, "i") } };
    }
    if (skillLevel) {
      query.skillLevel = skillLevel;
    }
    if (minRating) {
      query.rating = { $gte: parseFloat(minRating) };
    }

    const tutors = await User.find(query).sort({ rating: -1 });
    res.json(tutors);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
