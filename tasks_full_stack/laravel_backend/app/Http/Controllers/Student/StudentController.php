<?php

namespace App\Http\Controllers\Student;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class StudentController extends Controller
{
    public function dashboard()
    {
        return response()->json([
            'message' => 'Welcome to student dashboard'
        ]);
    }

    public function register(Request $req)
    {
        $req->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
        ]);

        $user = User::create([
            'name' => $req->name,
            'email' => $req->email,
            'role' => User::ROLE_STUDENT,
            'status' => User::STATUS_PENDING,
            // No registration number or password yet - will be set upon approval

        ]);

        return response()->json([
            'success' => true,
            'message' => 'Registration submitted successfully. Please wait for admin approval.',
            'data' => [
                'name' => $user->name,
                'email' => $user->email,
            ]
        ]);
    }

    public function store(Request $req)
    {
        $req->validate([
            'registration_number' => 'required|string',
            'password' => 'required|string'
        ]);

        $user = User::where('registration_number', $req->registration_number)->first();

        if (!$user || !Hash::check($req->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 403);
        }

        if ($user->role !== User::ROLE_STUDENT) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $token = $user->createToken($req->registration_number);

        return response()->json([
            'message' => 'Logged in Successfully',
            'user' => $user,
            'token' => $token->plainTextToken,
        ]);
    }
}
