import mongoose from "mongoose";
import dotenv from "dotenv";

// Load .env only in local dev
if (process.env.NODE_ENV !== "production") {
  dotenv.config();
}

// MongoDB connection (no retry loop for Vercel)
let isConnected = false;
export const connectToDatabase = async () => {
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
