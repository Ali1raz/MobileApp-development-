import express from "express";
import Task from "../models/Task.mjs";

const router = express.Router();

// Input validation middleware
const validateTaskInput = (req, res, next) => {
  const { title } = req.body;
  if (!title || title.trim().length === 0) {
    return res
      .status(400)
      .json({ message: "Title is required and cannot be empty" });
  }
  if (title.length > 200) {
    return res
      .status(400)
      .json({ message: "Title cannot be longer than 200 characters" });
  }
  next();
};

// Get all tasks with pagination and filtering
router.get("/", async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const completed =
      req.query.completed === "true"
        ? true
        : req.query.completed === "false"
        ? false
        : undefined;

    const query = {};
    if (completed !== undefined) {
      query.completed = completed;
    }

    const tasks = await Task.find(query)
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(limit)
      .lean();

    const total = await Task.countDocuments(query);

    res.json({
      tasks,
      currentPage: page,
      totalPages: Math.ceil(total / limit),
      totalTasks: total,
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error fetching tasks", error: error.message });
  }
});

// Get a single task by ID
router.get("/:id", async (req, res) => {
  try {
    const task = await Task.findById(req.params.id).lean();
    if (!task) {
      return res.status(404).json({ message: "Task not found" });
    }
    res.json(task);
  } catch (error) {
    if (error.name === "CastError") {
      return res.status(400).json({ message: "Invalid task ID format" });
    }
    res
      .status(500)
      .json({ message: "Error fetching task", error: error.message });
  }
});

// Create a new task
router.post("/", validateTaskInput, async (req, res) => {
  try {
    const task = new Task({
      title: req.body.title,
      completed: req.body.completed || false,
      priority: req.body.priority || 0,
    });
    const newTask = await task.save();
    res.status(201).json(newTask);
  } catch (error) {
    res
      .status(400)
      .json({ message: "Error creating task", error: error.message });
  }
});

// Update a task
router.patch("/:id", validateTaskInput, async (req, res) => {
  try {
    const updates = {};
    if (req.body.title !== undefined) updates.title = req.body.title;
    if (req.body.completed !== undefined)
      updates.completed = req.body.completed;
    if (req.body.priority !== undefined) updates.priority = req.body.priority;

    const task = await Task.findByIdAndUpdate(
      req.params.id,
      { $set: updates },
      { new: true, runValidators: true }
    );

    if (!task) {
      return res.status(404).json({ message: "Task not found" });
    }
    res.json(task);
  } catch (error) {
    if (error.name === "CastError") {
      return res.status(400).json({ message: "Invalid task ID format" });
    }
    res
      .status(400)
      .json({ message: "Error updating task", error: error.message });
  }
});

// Delete a task
router.delete("/:id", async (req, res) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);
    if (!task) {
      return res.status(404).json({ message: "Task not found" });
    }
    res.json({ message: "Task deleted successfully" });
  } catch (error) {
    if (error.name === "CastError") {
      return res.status(400).json({ message: "Invalid task ID format" });
    }
    res
      .status(500)
      .json({ message: "Error deleting task", error: error.message });
  }
});

export default router;
