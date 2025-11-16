import "dotenv/config";
import express from "express";
import cors from "cors";
import { router as profiles } from "./routes/profiles.js";  // ✅ use profiles router

const app = express();
const PORT = process.env.PORT || 3001;
const API_KEY = process.env.API_KEY;

app.use(cors());
app.use(express.json());

// Simple API key guard for local dev
app.use((req, res, next) => {
  const key = req.header("x-api-key");
  if (!API_KEY) {
    console.warn("[warn] API_KEY not set; allowing all requests (dev only)");
    return next();
  }
  if (key === API_KEY) return next();
  return res
    .status(401)
    .json({ error: "Unauthorized: x-api-key missing or invalid" });
});

app.get("/api/health", (req, res) => res.json({ ok: true }));

// ✅ mount profiles under /api/profiles
app.use("/api/profiles", profiles);

// 404
app.use((req, res) => res.status(404).json({ error: "Not Found" }));

// error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: "Server error" });
});

app.listen(PORT, () => {
  console.log(`[api] listening on http://localhost:${PORT}`);
});
