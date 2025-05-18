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
        $reg = auth()->user()->registration_number;

        DB::table('student_task')
            ->where('task_id', $taskId)
            ->where('registration_number', $reg)
            ->update(['is_completed' => true]);

        return response()->json(['message' => 'Task marked complete']);
    }
}
