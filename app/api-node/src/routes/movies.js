const express = require('express');
const router = express.Router();
const logger = require('../utils/logger');
const {
  validateCreateMovie,
  validateUpdateMovie,
  validateGetMovie,
  validateDeleteMovie,
  validateQueryMovies,
} = require('../middleware/validators');

const { createItem, getItem, queryItems, updateItem, deleteItem } = require('../db/firestore');

/**
 * GET /movies
 * Optional query: ?minRating=4
 */
router.get('/', validateQueryMovies, async (req, res) => {
  try {
    const minRating = req.query.minRating ? Number(req.query.minRating) : 0;

    logger.debug(`Fetching movies with minRating: ${minRating}`);
    const movies = await queryItems('rating', '>=', minRating);
    logger.info(`Retrieved ${movies.length} movies`);
    res.json(movies);
  } catch (err) {
    logger.error('Failed to fetch movies', { error: err.message, stack: err.stack });
    res.status(500).json({ message: 'Failed to fetch movies' });
  }
});

/**
 * GET /movies/:id
 */
router.get('/:id', validateGetMovie, async (req, res) => {
  try {
    logger.debug(`Fetching movie with id: ${req.params.id}`);
    const movie = await getItem(req.params.id);
    if (!movie) {
      logger.warn(`Movie not found: ${req.params.id}`);
      return res.status(404).json({ message: 'Movie not found' });
    }
    res.json(movie);
  } catch (err) {
    logger.error('Failed to fetch movie', { error: err.message, movieId: req.params.id });
    res.status(500).json({ message: 'Failed to fetch movie' });
  }
});

/**
 * POST /movies
 */
router.post('/', validateCreateMovie, async (req, res) => {
  try {
    const { title, rating } = req.body;

    logger.info(`Creating movie: ${title}`);
    const movie = await createItem({
      title,
      rating,
      createdAt: new Date(),
    });

    logger.info('Movie created successfully', { movieId: movie.id, title });
    res.status(201).json(movie);
  } catch (err) {
    logger.error('Failed to create movie', { error: err.message, body: req.body });
    res.status(500).json({ message: 'Failed to create movie' });
  }
});

/**
 * PUT /movies/:id
 * Replace entire document
 */
router.put('/:id', validateUpdateMovie, async (req, res) => {
  try {
    const { title, rating } = req.body;

    logger.info(`Updating movie: ${req.params.id}`);
    const updated = await updateItem(req.params.id, {
      title,
      rating,
      updatedAt: new Date(),
    });

    logger.info('Movie updated successfully', { movieId: req.params.id });
    res.json(updated);
  } catch (err) {
    logger.error('Failed to update movie', { error: err.message, movieId: req.params.id });
    res.status(500).json({ message: 'Failed to update movie' });
  }
});

/**
 * DELETE /movies/:id
 */
router.delete('/:id', validateDeleteMovie, async (req, res) => {
  try {
    logger.info(`Deleting movie: ${req.params.id}`);
    await deleteItem(req.params.id);
    logger.info('Movie deleted successfully', { movieId: req.params.id });
    res.status(204).send();
  } catch (err) {
    logger.error('Failed to delete movie', { error: err.message, movieId: req.params.id });
    res.status(500).json({ message: 'Failed to delete movie' });
  }
});

module.exports = router;
