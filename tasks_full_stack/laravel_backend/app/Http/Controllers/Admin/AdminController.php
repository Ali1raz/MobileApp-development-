<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminController extends Controller
{
    public function dashboard()
    {
        try {
            $stats = [
                'total_students' => User::where('role', User::ROLE_STUDENT)->count(),
                'total_tasks' => Task::count(),
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
            'email' => 'required|email|unique:users,email'
        ]);

        $regNo = 'STU' . strtoupper(Str::random(6));
        $password = Str::random(10);

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
            'password' => $password,
            'student' => $user,
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
            'email' => 'sometimes|email|unique:users,email',
            'password' => 'sometimes|string',
        ]);

        $student->name = $req->name ?? $student->name;
        $student->email = $req->email ?? $student->email;

        if ($req->filled('password')) {
            $student->password = Hash::make('password');
        }

        $student->save();

        return response()->json([
            'message' => 'Student updated successfully',
            'student' => $student
        ]);
    }

    public function deleteStudent(Request $req, string $registration_number)
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

        $student->delete();
        return response()->json([
            'message' => 'Student delted successfully',
        ]);
    }
}
