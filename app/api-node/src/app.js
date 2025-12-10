const express = require("express");
const moviesRouter = require("./routes/movies");

const app = express();

app.use(express.json());

// Health endpoint (for Kubernetes liveness/readiness probes)
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

app.use("/movies", moviesRouter);

module.exports = app;
