const request = require("supertest");
const app = require("../src/app");

describe("Movies API", () => {
  it("GET /movies should return a list", async () => {
    const res = await request(app).get("/movies");
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it("POST /movies should create a movie", async () => {
    const res = await request(app)
      .post("/movies")
      .send({ title: "Avatar 2", rating: 4 });

    expect(res.statusCode).toBe(201);
    expect(res.body.title).toBe("Avatar 2");
  });
});
