# Movie Review API Documentation

## Overview

A simple REST API case study for managing movie reviews with ratings.

**Base URL**: `http://localhost:3000`

**Version**: 1.0.0

---

## Features
- ✅ RESTful API for movie reviews
- ✅ Input validation with express-validator
- ✅ Structured logging with Winston
- ✅ Comprehensive test coverage (Jest)
- ✅ Code quality tools (ESLint, Prettier)
- ✅ Pre-commit hooks (Husky + lint-staged)
- ✅ Security scanning (Trivy in CI)
- ✅ Automated dependency updates (Dependabot)


## Prerequisities
Need to export two variables first and firestore db has to be running already in GCP:
```bash
# Project ID created with terraform and collection name
export FIRESTORE_PROJECT_ID=movie-review-platform8451
export FIRESTORE_COLLECTION=movies
```

## Endpoints

### Health Check

#### `GET /health`

Check if the API is running (used by Kubernetes probes).

**Response**

```json
{
  "status": "ok"
}
```

---

### Get All Movies

#### `GET /movies`

Retrieve a list of all movies, optionally filtered by minimum rating.

**Query Parameters**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| minRating | integer | No | Filter movies with rating >= this value (1-5) |

**Example Request**

```bash
# Get all movies
curl http://localhost:3000/movies

# Get movies with rating >= 4
curl http://localhost:3000/movies?minRating=4
```

**Success Response (200 OK)**

```json
[
  {
    "id": "abc123",
    "title": "Inception",
    "rating": 5,
    "createdAt": "2024-01-15T10:30:00.000Z"
  },
  {
    "id": "def456",
    "title": "Avatar 2",
    "rating": 4,
    "createdAt": "2024-01-16T14:20:00.000Z"
  }
]
```

**Error Response (400 Bad Request)**

```json
{
  "message": "Validation failed",
  "errors": [
    {
      "field": "minRating",
      "message": "minRating must be an integer between 1 and 5",
      "value": "10"
    }
  ]
}
```

---

### Get Single Movie

#### `GET /movies/:id`

Retrieve details of a specific movie by ID.

**URL Parameters**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | The unique movie ID |

**Example Request**

```bash
curl http://localhost:3000/movies/abc123
```

**Success Response (200 OK)**

```json
{
  "id": "abc123",
  "title": "Inception",
  "rating": 5,
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

**Error Response (404 Not Found)**

```json
{
  "message": "Movie not found"
}
```

---

### Create Movie

#### `POST /movies`

Create a new movie entry.

**Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Movie title (1-200 characters) |
| rating | integer | Yes | Movie rating (1-5) |

**Example Request**

```bash
curl -X POST http://localhost:3000/movies \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Matrix",
    "rating": 5
  }'
```

**Success Response (201 Created)**

```json
{
  "id": "xyz789",
  "title": "The Matrix",
  "rating": 5,
  "createdAt": "2024-01-17T09:15:00.000Z"
}
```

**Error Response (400 Bad Request)**

```json
{
  "message": "Validation failed",
  "errors": [
    {
      "field": "rating",
      "message": "Rating must be an integer between 1 and 5",
      "value": "6"
    }
  ]
}
```

---

### Update Movie

#### `PUT /movies/:id`

Update an existing movie (replaces entire document).

**URL Parameters**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | The unique movie ID |

**Request Body**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Movie title (1-200 characters) |
| rating | integer | Yes | Movie rating (1-5) |

**Example Request**

```bash
curl -X PUT http://localhost:3000/movies/xyz789 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "The Matrix Reloaded",
    "rating": 4
  }'
```

**Success Response (200 OK)**

```json
{
  "id": "xyz789",
  "title": "The Matrix Reloaded",
  "rating": 4,
  "updatedAt": "2024-01-18T11:45:00.000Z"
}
```

**Error Response (400 Bad Request)**

```json
{
  "message": "Validation failed",
  "errors": [...]
}
```

---

### Delete Movie

#### `DELETE /movies/:id`

Delete a movie by ID.

**URL Parameters**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | string | Yes | The unique movie ID |

**Example Request**

```bash
curl -X DELETE http://localhost:3000/movies/xyz789
```

**Success Response (204 No Content)**
No response body.

**Error Response (500 Internal Server Error)**

```json
{
  "message": "Failed to delete movie"
}
```

---

## Validation Rules

### Movie Title

- **Required**: Yes
- **Type**: String
- **Min Length**: 1 character
- **Max Length**: 200 characters
- **Trimming**: Leading/trailing whitespace is automatically removed

### Movie Rating

- **Required**: Yes
- **Type**: Integer
- **Min Value**: 1
- **Max Value**: 5

### Movie ID (URL parameter)

- **Required**: Yes
- **Type**: String
- **Must not be empty**

### Query Parameter: minRating

- **Required**: No
- **Type**: Integer
- **Min Value**: 1
- **Max Value**: 5

---

## Error Handling

All errors follow a consistent format:

### Validation Errors (400)

```json
{
  "message": "Validation failed",
  "errors": [
    {
      "field": "rating",
      "message": "Rating must be an integer between 1 and 5",
      "value": "invalid-value"
    }
  ]
}
```

### Not Found (404)

```json
{
  "message": "Movie not found"
}
```

### Server Errors (500)

```json
{
  "message": "Failed to fetch movies"
}
```

---

## Testing the API

### Using curl

```bash
# Health check
curl http://localhost:3000/health

# Get all movies
curl http://localhost:3000/movies

# Create a movie
curl -X POST http://localhost:3000/movies \
  -H "Content-Type: application/json" \
  -d '{"title": "Interstellar", "rating": 5}'

# Get specific movie (replace ID)
curl http://localhost:3000/movies/YOUR_MOVIE_ID

# Update movie
curl -X PUT http://localhost:3000/movies/YOUR_MOVIE_ID \
  -H "Content-Type: application/json" \
  -d '{"title": "Interstellar", "rating": 4}'

# Delete movie
curl -X DELETE http://localhost:3000/movies/YOUR_MOVIE_ID
```

### Using httpie (xh)

```bash
# Get all movies
xh http://localhost:3000/movies

# Create a movie
xh POST http://localhost:3000/movies title="Dune" rating:=5

# Filter by rating
xh http://localhost:3000/movies minRating==4
```

---

## Development Setup

1. **Install dependencies**

   ```bash
   npm install
   ```

2. **Run tests**

   ```bash
   npm test
   npm run test:coverage
   ```

3. **Run linter**

   ```bash
   npm run lint
   npm run lint:fix
   ```

4. **Format code**

   ```bash
   npm run format
   npm run format:check
   ```

5. **Start development server**

   ```bash
   npm run dev
   ```

6. **Start production server**
   ```bash
   npm start
   ```

---

## Logging

The API uses structured logging with Winston. Log levels:

- **debug**: Detailed information for debugging
- **info**: General informational messages
- **warn**: Warning messages (e.g., invalid requests)
- **error**: Error messages with stack traces

Logs are written to:

- Console (colored output)
- `logs/combined.log` (all logs)
- `logs/error.log` (errors only)

Set log level via environment variable:

```bash
LOG_LEVEL=debug npm start
```

---

## Environment Variables

| Variable  | Default     | Description                              |
| --------- | ----------- | ---------------------------------------- |
| PORT      | 3000        | Server port                              |
| LOG_LEVEL | info        | Logging level (debug, info, warn, error) |
| NODE_ENV  | development | Environment (development, production)    |

---

## Next Steps

- [ ] Add authentication (JWT)
- [ ] Add pagination for GET /movies
- [ ] Add movie genres/categories
- [ ] Add movie descriptions
- [ ] Add user ratings (multiple users)
- [ ] Add OpenAPI/Swagger spec

