const express = require("express");
const router = express.Router();

// In-memory storage (replace with CloudSQL later)
let movies = [
  { id: 1, title: "American Psycho", rating: 10 },
  { id: 2, title: "Interstellar", rating: 2 }
];

router.get("/", (req, res) => {
  res.json(movies);
});

router.post("/", (req, res) => {
  const { title, rating } = req.body;

  if (!title || rating == null) {
    return res.status(400).json({ message: "title and rating required" });
  }

  const newMovie = {
    id: movies.length + 1,
    title,
    rating
  };

  movies.push(newMovie);

  res.status(201).json(newMovie);
});

module.exports = router;
