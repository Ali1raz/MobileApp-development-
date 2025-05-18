<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminController extends Controller
{
    public function dashboard()
    {
        return response()->json([
            'message' => 'Welcome to admin dashboard'
        ]);
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
}
