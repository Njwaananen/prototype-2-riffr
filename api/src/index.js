// api/src/index.js
import "dotenv/config";
import express from "express";
import cors from "cors";
import serverless from "serverless-http";

import { router as assignments } from "./routes/assignments.js";
import { router as profiles } from "./routes/profiles.js";

const app = express();

// middleware
app.use(cors());
app.use(express.json());

// simple health check (no DB)
app.get("/api/health", (req, res) => {
  res.json({ ok: true });
});

// routes that hit Supabase
app.use("/api/assignments", assignments);
app.use("/api/profiles", profiles);

// 404
app.use((req, res) => {
  res.status(404).json({ error: "Not Found" });
});

// error handler
app.use((err, req, res, next) => {
  console.error("[api] error:", err);
  res.status(500).json({ error: "Server error" });
});

// IMPORTANT: no app.listen() in Lambda.
// Export the handler for Serverless / AWS Lambda:
export const handler = serverless(app);
