const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const authRoutes = require("./routes/auth");
const userRoutes = require("./routes/users");
const sessionRoutes = require("./routes/sessions");
const feedbackRoutes = require("./routes/feedback");
const tutorRoutes = require("./routes/tutors");

const app = express();
const PORT = 3000;

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(
  cors({
    credentials: true,
    origin: ["http://localhost:24648"],
  }),
);
app.use(express.json());

// ── MongoDB Connection ────────────────────────────────────────────────────────
mongoose
  .connect("mongodb://localhost:27017/peer_tutoring")
  .then(() => console.log("Connected to local MongoDB - peer_tutoring"))
  .catch((err) => console.error("MongoDB connection error:", err));

// ── Routes ────────────────────────────────────────────────────────────────────
app.use("/api/auth", authRoutes); // ← NEW: Auth routes
app.use("/api/users", userRoutes);
app.use("/api/sessions", sessionRoutes);
app.use("/api/feedback", feedbackRoutes);
app.use("/api/tutors", tutorRoutes);

// ── Health check ──────────────────────────────────────────────────────────────
app.get("/", (req, res) => {
  res.json({ status: "ok", message: "PeerTutor API is running" });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
