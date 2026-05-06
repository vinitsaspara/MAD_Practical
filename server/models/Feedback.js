const mongoose = require("mongoose");

const FeedbackSchema = new mongoose.Schema(
  {
    feedbackId: { type: String, required: true, unique: true },
    sessionId: { type: String, required: true },
    tutorId: { type: String, required: true },
    learnerId: { type: String, required: true },
    rating: { type: Number, min: 1, max: 5, required: true },
    comment: { type: String },
    givenBy: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Feedback", FeedbackSchema);
