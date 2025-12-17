const express = require("express");
const router = express.Router();

const {
  createItem,
  getItem,
  queryItems,
  updateItem,
  deleteItem,
} = require("../db/firestore");

/**
 * GET /movies
 * Optional query: ?minRating=4
 */
router.get("/", async (req, res) => {
  try {
    const minRating = req.query.minRating
      ? Number(req.query.minRating)
      : 0;

    const movies = await queryItems("rating", ">=", minRating);
    res.json(movies);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch movies" });
  }
});

/**
 * GET /movies/:id
 */
router.get("/:id", async (req, res) => {
  try {
    const movie = await getItem(req.params.id);
    if (!movie) {
      return res.status(404).json({ message: "Movie not found" });
    }
    res.json(movie);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to fetch movie" });
  }
});

/**
 * POST /movies
 */
router.post("/", async (req, res) => {
  try {
    const { title, rating } = req.body;

    if (!title || rating == null) {
      return res.status(400).json({ message: "title and rating required" });
    }

    const movie = await createItem({
      title,
      rating,
      createdAt: new Date(),
    });

    res.status(201).json(movie);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to create movie" });
  }
});

/**
 * PUT /movies/:id
 * Replace entire document
 */
router.put("/:id", async (req, res) => {
  try {
    const { title, rating } = req.body;

    if (!title || rating == null) {
      return res.status(400).json({ message: "title and rating required" });
    }

    const updated = await updateItem(req.params.id, {
      title,
      rating,
      updatedAt: new Date(),
    });

    res.json(updated);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to update movie" });
  }
});

/**
 * DELETE /movies/:id
 */
router.delete("/:id", async (req, res) => {
  try {
    await deleteItem(req.params.id);
    res.status(204).send();
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Failed to delete movie" });
  }
});

module.exports = router;
