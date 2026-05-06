const mongoose = require("mongoose");

const SessionSchema = new mongoose.Schema(
  {
    sessionId: { type: String, required: true, unique: true },
    tutorId: { type: String, required: true },
    learnerId: { type: String, required: true },
    tutorName: { type: String },
    learnerName: { type: String },
    subject: { type: String, required: true },
    dateTime: { type: Date, required: true },
    status: {
      type: String,
      enum: ["scheduled", "completed", "cancelled"],
      default: "scheduled",
    },
    notes: { type: String },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Session", SessionSchema);
