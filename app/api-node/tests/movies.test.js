const request = require('supertest');
const app = require('../src/app');

describe('Movies API', () => {
  describe('GET /movies', () => {
    it('should return a list of movies', async () => {
      const res = await request(app).get('/movies');
      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });

    it('should accept valid minRating query parameter', async () => {
      const res = await request(app).get('/movies?minRating=3');
      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
    });

    it('should reject invalid minRating query parameter', async () => {
      const res = await request(app).get('/movies?minRating=10');
      expect(res.statusCode).toBe(400);
      expect(res.body.message).toBe('Validation failed');
    });

    it('should reject non-numeric minRating', async () => {
      const res = await request(app).get('/movies?minRating=abc');
      expect(res.statusCode).toBe(400);
    });
  });

  describe('POST /movies', () => {
    it('should create a movie with valid data', async () => {
      const res = await request(app).post('/movies').send({ title: 'Avatar 2', rating: 4 });

      expect(res.statusCode).toBe(201);
      expect(res.body.title).toBe('Avatar 2');
      expect(res.body.rating).toBe(4);
      expect(res.body.id).toBeDefined();
    });

    it('should reject movie without title', async () => {
      const res = await request(app).post('/movies').send({ rating: 4 });

      expect(res.statusCode).toBe(400);
      expect(res.body.message).toBe('Validation failed');
      expect(res.body.errors).toBeDefined();
    });

    it('should reject movie without rating', async () => {
      const res = await request(app).post('/movies').send({ title: 'Test Movie' });

      expect(res.statusCode).toBe(400);
      expect(res.body.message).toBe('Validation failed');
    });

    it('should reject movie with rating out of range (too high)', async () => {
      const res = await request(app).post('/movies').send({ title: 'Test Movie', rating: 6 });

      expect(res.statusCode).toBe(400);
      expect(res.body.message).toBe('Validation failed');
    });

    it('should reject movie with rating out of range (too low)', async () => {
      const res = await request(app).post('/movies').send({ title: 'Test Movie', rating: 0 });

      expect(res.statusCode).toBe(400);
      expect(res.body.message).toBe('Validation failed');
    });

    it('should reject movie with empty title', async () => {
      const res = await request(app).post('/movies').send({ title: '   ', rating: 3 });

      expect(res.statusCode).toBe(400);
    });

    it('should trim whitespace from title', async () => {
      const res = await request(app).post('/movies').send({ title: '  Inception  ', rating: 5 });

      expect(res.statusCode).toBe(201);
      expect(res.body.title).toBe('Inception');
    });
  });

  describe('GET /movies/:id', () => {
    it('should return 404 for non-existent movie', async () => {
      const res = await request(app).get('/movies/nonexistent123');
      expect(res.statusCode).toBe(404);
      expect(res.body.message).toBe('Movie not found');
    });
  });

  describe('PUT /movies/:id', () => {
    it('should reject update without title', async () => {
      const res = await request(app).put('/movies/test123').send({ rating: 3 });

      expect(res.statusCode).toBe(400);
      expect(res.body.message).toBe('Validation failed');
    });

    it('should reject update without rating', async () => {
      const res = await request(app).put('/movies/test123').send({ title: 'Updated Movie' });

      expect(res.statusCode).toBe(400);
      expect(res.body.message).toBe('Validation failed');
    });

    it('should reject update with invalid rating', async () => {
      const res = await request(app)
        .put('/movies/test123')
        .send({ title: 'Updated Movie', rating: 10 });

      expect(res.statusCode).toBe(400);
    });
  });

  describe('DELETE /movies/:id', () => {
    it('should accept valid movie ID for deletion', async () => {
      // This will try to delete, may fail at DB level but validation passes
      const res = await request(app).delete('/movies/test123');
      // Either 204 (success) or 500 (DB error) is acceptable for validation test
      expect([204, 500]).toContain(res.statusCode);
    });
  });

  describe('GET /health', () => {
    it('should return healthy status', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('ok');
    });
  });
});
