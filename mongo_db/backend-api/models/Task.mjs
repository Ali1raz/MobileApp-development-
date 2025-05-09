import mongoose from "mongoose";

const TaskSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Title is required"],
      trim: true,
      minlength: [1, "Title cannot be empty"],
      maxlength: [200, "Title cannot be longer than 200 characters"],
    },
    completed: {
      type: Boolean,
      default: false,
      index: true,
    },
    priority: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes
TaskSchema.index({ createdAt: -1 });
TaskSchema.index({ title: "text" });

// Virtual for task status
TaskSchema.virtual("status").get(function () {
  return this.completed ? "completed" : "pending";
});

// Pre-save middleware
TaskSchema.pre("save", function (next) {
  if (this.isModified("title")) {
    this.title = this.title.trim();
  }
  next();
});

const Task = mongoose.model("Task", TaskSchema);
export default Task;
