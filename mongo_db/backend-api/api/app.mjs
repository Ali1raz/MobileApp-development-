import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import mongoose from "mongoose";
import compression from "compression";
import tasksRouter from "../routes/tasks.mjs";

// Load .env only in local dev
if (process.env.NODE_ENV !== "production") {
  dotenv.config();
}

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());
app.use(compression());

// MongoDB connection (no retry loop for Vercel)
let isConnected = false;
const connectToDatabase = async () => {
  if (isConnected) return;
  if (!process.env.MONGODB_URI) {
    throw new Error("Missing MongoDB URI!");
  }

  try {
    await mongoose.connect(process.env.MONGODB_URI, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      family: 4,
    });

    isConnected = true;
    console.log("MongoDB connected");

    mongoose.connection.on("error", (err) =>
      console.error("Mongo error:", err)
    );
    mongoose.connection.on("disconnected", () => {
      console.warn("Mongo disconnected");
      isConnected = false;
    });

    process.on("SIGINT", async () => {
      await mongoose.connection.close();
      console.log("MongoDB disconnected on app termination");
      process.exit(0);
    });
  } catch (err) {
    console.error("MongoDB failed to connect:", err.message);
  }
};

await connectToDatabase();

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
