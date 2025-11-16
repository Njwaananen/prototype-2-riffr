// api/src/routes/profiles.js
import express from "express";
import { supabase } from "../lib/supabase.js";

export const router = express.Router();

// GET /api/profiles  (read 1)
router.get("/", async (req, res, next) => {
  try {
    const { data, error } = await supabase
      .from("profiles")
      .select("profile_id, user_id, display_name, bio, location_text, visibility");

    if (error) throw error;
    res.json(data);
  } catch (err) {
    next(err);
  }
});

// GET /api/profiles/:id  (read 2)
router.get("/:id", async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from("profiles")
      .select("profile_id, user_id, display_name, bio, location_text, visibility")
      .eq("profile_id", id)
      .single();

    if (error && error.code === "PGRST116") {
      return res.status(404).json({ error: "Profile not found" });
    }
    if (error) throw error;

    res.json(data);
  } catch (err) {
    next(err);
  }
});

// GET /api/profiles/search/by-genre?genre=hip-hop  (read 3)
router.get("/search/by-genre", async (req, res, next) => {
  try {
    const genreName = req.query.genre;
    if (!genreName) {
      return res.status(400).json({ error: "Missing genre query parameter" });
    }

    const { data: genreData, error: genreError } = await supabase
      .from("genres")
      .select("genre_id")
      .eq("name", genreName)
      .single();
    if (genreError) throw genreError;

    const { data: userGenres, error: ugError } = await supabase
      .from("user_genre")
      .select("user_id")
      .eq("genre_id", genreData.genre_id);
    if (ugError) throw ugError;

    const userIds = userGenres.map((u) => u.user_id);
    if (userIds.length === 0) return res.json([]);

    const { data: profiles, error: profError } = await supabase
      .from("profiles")
      .select("profile_id, user_id, display_name, bio, location_text, visibility")
      .in("user_id", userIds);
    if (profError) throw profError;

    res.json(profiles);
  } catch (err) {
    next(err);
  }
});

// POST /api/profiles  (write 1)
router.post("/", async (req, res, next) => {
  try {
    const { email, username, password, display_name, bio, location_text } = req.body;

    if (!email || !username || !password || !display_name) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const { data: userRow, error: userError } = await supabase
      .from("users")
      .insert({
        email,
        username,
        password_hash: password,
      })
      .select("user_id")
      .single();
    if (userError) throw userError;

    const { data: profileRow, error: profileError } = await supabase
      .from("profiles")
      .insert({
        user_id: userRow.user_id,
        display_name,
        bio,
        location_text,
      })
      .select("*")
      .single();
    if (profileError) throw profileError;

    res.status(201).json(profileRow);
  } catch (err) {
    if (err.message?.includes("users_email_key")) {
      return res.status(409).json({ error: "Email already exists" });
    }
    if (err.message?.includes("users_username_key")) {
      return res.status(409).json({ error: "Username already exists" });
    }
    next(err);
  }
});
