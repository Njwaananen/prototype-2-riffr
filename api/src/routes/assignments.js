
import express from "express";
import { z } from "zod";
import { supabase } from "../lib/supabase.js";

export const router = express.Router();

// GET /api/assignments -> list (limit 50)
router.get("/", async (req, res) => {
  const { data, error } = await supabase
    .from("assignments") // TODO: rename to your core table if different
    .select("*")
    .limit(50);
  if (error) return res.status(500).json({ error: error.message });
  return res.json(data);
});

// GET /api/assignments/:id -> detail
router.get("/:id", async (req, res) => {
  const id = Number(req.params.id);
  if (Number.isNaN(id)) return res.status(400).json({ error: "Invalid id" });
  const { data, error } = await supabase
    .from("assignments")
    .select("*")
    .eq("id", id)
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  if (!data) return res.status(404).json({ error: "Not found" });
  return res.json(data);
});

// POST /api/assignments -> create
const NewAssignment = z.object({
  title: z.string().min(1),
  dueDate: z.string().optional(), // ISO date
});

router.post("/", async (req, res) => {
  const parse = NewAssignment.safeParse(req.body);
  if (!parse.success) return res.status(400).json({ error: parse.error.flatten() });

  const { data, error } = await supabase
    .from("assignments")
    .insert([parse.data])
    .select("*")
    .maybeSingle();
  if (error) return res.status(500).json({ error: error.message });
  return res.status(201).json(data);
});
