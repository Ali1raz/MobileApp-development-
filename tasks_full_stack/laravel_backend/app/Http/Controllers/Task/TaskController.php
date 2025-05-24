<?php

namespace App\Http\Controllers\Task;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TaskController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        // If Admin: return all tasks with assigned users
        if ($user->role === User::ROLE_ADMIN) {
            $tasks = Task::with(['students:id,name,registration_number'])->get();

            return response()->json([
                'role' => 'admin',
                'tasks' => $tasks
            ]);
        }

        // If Student: return only their tasks
        if ($user->role === User::ROLE_STUDENT) {
            $tasks = $user->tasks()->withPivot('is_completed')->get();

            return response()->json([
                'role' => 'student',
                'tasks' => $tasks
            ]);
        }

        return response()->json(['message' => 'Unauthorized'], 403);
    }

    public function createTask(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'description' => 'nullable|string',
            'due_date' => 'nullable|date',
            'registration_numbers' => 'required|array',
            'registration_numbers.*' => 'exists:users,registration_number'
        ]);

        $task = Task::create([
            'title' => $request->title,
            'description' => $request->description,
            'due_date' => $request->due_date,
        ]);

        foreach ($request->registration_numbers as $reg) {
            DB::table('student_task')->insert([
                'task_id' => $task->id,
                'registration_number' => $reg,
                'created_at' => now(),
                'updated_at' => now()
            ]);
        }

        return response()->json(['message' => 'Task assigned using registration numbers', 'task' => $task]);
    }

    public function taskProgress($taskId)
    {
        $task = Task::with(['students'])->findOrFail($taskId);

        $progress = $task->students->map(function ($student) {
            return [
                'student_id' => $student->id,
                'name' => $student->name,
                'is_completed' => $student->pivot->is_completed
            ];
        });

        return response()->json(['task' => $task->title, 'progress' => $progress]);
    }

    public function markComplete($taskId)
    {
        try {
            $user = auth()->user();
            $task = Task::findOrFail($taskId);

            // Check if the task is assigned to the student
            $studentTask = DB::table('student_task')
                ->where('task_id', $taskId)
                ->where('registration_number', $user->registration_number)
                ->first();

            if (!$studentTask) {
                return response()->json([
                    'message' => 'Task not assigned to you',
                    'error' => 'TASK_NOT_ASSIGNED'
                ], 403);
            }

            // Check if task is already completed
            if ($studentTask->is_completed) {
                return response()->json([
                    'message' => 'Task already completed',
                    'error' => 'TASK_ALREADY_COMPLETED'
                ], 400);
            }

            // Mark task as completed
            DB::table('student_task')
                ->where('task_id', $taskId)
                ->where('registration_number', $user->registration_number)
                ->update([
                    'is_completed' => true,
                    'updated_at' => now()
                ]);

            return response()->json([
                'message' => 'Task marked as complete',
                'task' => [
                    'id' => $task->id,
                    'title' => $task->title,
                    'completed_at' => now()
                ]
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'message' => 'Task not found',
                'error' => 'TASK_NOT_FOUND'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'An error occurred while completing the task',
                'error' => 'INTERNAL_SERVER_ERROR'
            ], 500);
        }
    }

    public function deleteTask($taskId)
    {
        try {
            $task = Task::findOrFail($taskId);

            // Delete the task (this will automatically delete related records in student_task table due to foreign key constraints)
            $task->delete();

            return response()->json([
                'message' => 'Task deleted successfully'
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'message' => 'Task not found',
                'error' => 'TASK_NOT_FOUND'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'An error occurred while deleting the task',
                'error' => 'INTERNAL_SERVER_ERROR'
            ], 500);
        }
    }

    public function updateTask(Request $request, $taskId)
    {
        try {
            $request->validate([
                'title' => 'sometimes|string',
                'description' => 'nullable|string',
                'due_date' => 'nullable|date',
                'registration_numbers' => 'sometimes|array',
                'registration_numbers.*' => 'exists:users,registration_number'
            ]);

            $task = Task::findOrFail($taskId);

            // Update task details if provided
            if ($request->has('title')) {
                $task->title = $request->title;
            }
            if ($request->has('description')) {
                $task->description = $request->description;
            }
            if ($request->has('due_date')) {
                $task->due_date = $request->due_date;
            }
            $task->save();

            // Update student assignments if provided
            if ($request->has('registration_numbers')) {
                // Get current assignments
                $currentAssignments = DB::table('student_task')
                    ->where('task_id', $taskId)
                    ->pluck('registration_number')
                    ->toArray();

                // Get new assignments
                $newAssignments = $request->registration_numbers;

                // Find assignments to remove (in current but not in new)
                $toRemove = array_diff($currentAssignments, $newAssignments);
                if (!empty($toRemove)) {
                    DB::table('student_task')
                        ->where('task_id', $taskId)
                        ->whereIn('registration_number', $toRemove)
                        ->delete();
                }

                // Find assignments to add (in new but not in current)
                $toAdd = array_diff($newAssignments, $currentAssignments);
                foreach ($toAdd as $reg) {
                    DB::table('student_task')->insert([
                        'task_id' => $taskId,
                        'registration_number' => $reg,
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }
            }

            // Load the updated task with its students
            $updatedTask = Task::with(['students:id,name,registration_number'])
                ->find($taskId);

            return response()->json([
                'message' => 'Task updated successfully',
                'task' => $updatedTask
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'message' => 'Task not found',
                'error' => 'TASK_NOT_FOUND'
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'An error occurred while updating the task',
                'error' => 'INTERNAL_SERVER_ERROR'
            ], 500);
        }
    }
}
