const { body, param, query, validationResult } = require('express-validator');

// Middleware to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      message: 'Validation failed',
      errors: errors.array().map((err) => ({
        field: err.path,
        message: err.msg,
        value: err.value,
      })),
    });
  }
  next();
};

// Validation rules for creating a movie
const validateCreateMovie = [
  body('title')
    .trim()
    .notEmpty()
    .withMessage('Title is required')
    .isLength({ min: 1, max: 200 })
    .withMessage('Title must be between 1 and 200 characters'),

  body('rating')
    .notEmpty()
    .withMessage('Rating is required')
    .isInt({ min: 1, max: 5 })
    .withMessage('Rating must be an integer between 1 and 5'),

  handleValidationErrors,
];

// Validation rules for updating a movie
const validateUpdateMovie = [
  param('id').trim().notEmpty().withMessage('Movie ID is required'),

  body('title')
    .trim()
    .notEmpty()
    .withMessage('Title is required')
    .isLength({ min: 1, max: 200 })
    .withMessage('Title must be between 1 and 200 characters'),

  body('rating')
    .notEmpty()
    .withMessage('Rating is required')
    .isInt({ min: 1, max: 5 })
    .withMessage('Rating must be an integer between 1 and 5'),

  handleValidationErrors,
];

// Validation rules for getting a movie by ID
const validateGetMovie = [
  param('id').trim().notEmpty().withMessage('Movie ID is required'),

  handleValidationErrors,
];

// Validation rules for deleting a movie
const validateDeleteMovie = [
  param('id').trim().notEmpty().withMessage('Movie ID is required'),

  handleValidationErrors,
];

// Validation rules for query parameters
const validateQueryMovies = [
  query('minRating')
    .optional()
    .isInt({ min: 1, max: 5 })
    .withMessage('minRating must be an integer between 1 and 5'),

  handleValidationErrors,
];

module.exports = {
  validateCreateMovie,
  validateUpdateMovie,
  validateGetMovie,
  validateDeleteMovie,
  validateQueryMovies,
};
