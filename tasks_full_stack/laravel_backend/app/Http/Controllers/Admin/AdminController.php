<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class AdminController extends Controller
{
    public function dashboard()
    {
        try {
            $stats = [
                'total_students' => User::where('role', User::ROLE_STUDENT)->count(),
                'total_tasks' => Task::count(),
                'task_completion' => [
                    'total_completed' => DB::table('student_task')->where('is_completed', true)->count(),
                    'total_pending' => DB::table('student_task')->where('is_completed', false)->count(),
                    'completion_rate' => DB::table('student_task')->count() > 0
                        ? round((DB::table('student_task')->where('is_completed', true)->count() / DB::table('student_task')->count()) * 100, 2)
                        : 0
                ],
                'recent_activities' => [
                    'recent_tasks' => Task::with(['students:id,name,registration_number'])
                        ->latest()
                        ->take(5)
                        ->get(),
                    'recent_completions' => DB::table('student_task')
                        ->join('users', 'student_task.registration_number', '=', 'users.registration_number')
                        ->join('tasks', 'student_task.task_id', '=', 'tasks.id')
                        ->where('is_completed', true)
                        ->select('users.name as student_name', 'tasks.title as task_title', 'student_task.updated_at as completed_at')
                        ->latest('completed_at')
                        ->take(5)
                        ->get()
                ],
                'student_performance' => DB::table('student_task')
                    ->join('users', 'student_task.registration_number', '=', 'users.registration_number')
                    ->select(
                        'users.name',
                        'users.registration_number',
                        DB::raw('COUNT(*) as total_tasks'),
                        DB::raw('SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_tasks'),
                        DB::raw('ROUND((SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as completion_rate')
                    )
                    ->groupBy('users.registration_number', 'users.name')
                    ->orderBy('completion_rate', 'desc')
                    ->take(5)
                    ->get()
            ];

            return response()->json([
                'success' => true,
                'stats' => $stats
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error fetching statistics',
                'error' => 'INTERNAL_SERVER_ERROR'
            ], 500);
        }
    }

    public function registerStudent(Request $req)
    {
        $req->validate([
            'name' => 'required|string',
            'email' => 'required|email|unique:users,email',
            'password' => 'nullable|string|min:6'
        ]);

        $regNo = 'STU' . strtoupper(Str::random(6));
        $password = $req->exists('password') && !empty($req->password) ? $req->password : Str::random(10);

        $user = User::create([
            'name' => $req->name,
            'email' => $req->email,
            'registration_number' => $regNo,
            'password' => Hash::make($password),
            'role' => 'student',
        ]);

        return response()->json([
            'message' => 'Student registered successfully',
            'registration_number' => $regNo,
        ]);
    }

    public function listStudents()
    {
        if (auth()->user()->role !== User::ROLE_ADMIN) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $students = User::where('role', User::ROLE_STUDENT)->get();

        return response()->json([
            'students' => $students
        ]);
    }

    public function viewStudent(string $registration_number)
    {
        if (auth()->user()->role !== User::ROLE_ADMIN) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $student = User::where('registration_number', $registration_number)->first();

        if (!$student) {
            return response()->json([
                'message' => 'Student not found'
            ]);
        }

        return response()->json([
            'student' => $student
        ]);
    }

    public function updateStudent(Request $req, string $registration_number)
    {
        if (auth()->user()->role !== User::ROLE_ADMIN) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $student = User::where('registration_number', $registration_number)->where('role', User::ROLE_STUDENT)->first();

        if (!$student) {
            return response()->json([
                'message' => 'Student not found'
            ]);
        }

        $req->validate([
            'name' => 'sometimes|string',
            'email' => 'sometimes|email|unique:users,email,' . $student->id,
            'password' => 'sometimes|string|min:6',
        ]);

        $student->name = $req->name ?? $student->name;
        $student->email = $req->email ?? $student->email;

        if ($req->exists('password') && !empty($req->password)) {
            $student->password = Hash::make($req->password);
        }

        $student->save();

        return response()->json([
            'message' => 'Student updated successfully',
            'registration_number' => $student->registration_number,
        ]);
    }


    public function deleteStudent(Request $req, string $registration_number)
    {
        if (auth()->user()->role !== User::ROLE_ADMIN) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $student = User::where('registration_number', $registration_number)
            ->where('role', User::ROLE_STUDENT)
            ->with('tasks') // Eager load tasks
            ->first();

        if (!$student) {
            return response()->json([
                'message' => 'Student not found'
            ]);
        }

        foreach ($student->tasks as $task) {
            if ($task->students()->count() === 1) {
                $task->delete();
            }
        }

        // Delete the student
        $student->delete();

        return response()->json([
            'message' => 'Student deleted successfully',
        ]);
    }
}
