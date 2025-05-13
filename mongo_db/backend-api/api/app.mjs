import express from "express";
import cors from "cors";
import compression from "compression";
import tasksRouter from "../routes/tasks.mjs";

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());
app.use(compression());

// Routes
app.use("/api/tasks", tasksRouter);

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    status: "error",
    message: "Internal Server Error",
    error: process.env.NODE_ENV === "development" ? err.message : undefined,
  });
});

// Local dev listener
let serverStarted = false;

if (process.env.VERCEL !== "1" && !serverStarted) {
  app.listen(PORT, () => {
    console.log(`✅ Server running locally at http://localhost:${PORT}`);
    serverStarted = true;
  });
}

export default app;
