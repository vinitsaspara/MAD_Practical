const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  _id: { type: String, required: true },     
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['tutor', 'learner', 'both'], default: 'learner' },
  subjects: [{ type: String }],
  skillLevel: { type: String, enum: ['beginner', 'intermediate', 'advanced'], default: 'beginner' },
  availability: [{ type: String }],
  rating: { type: Number, default: 0 },
  totalSessions: { type: Number, default: 0 },
  bio: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
