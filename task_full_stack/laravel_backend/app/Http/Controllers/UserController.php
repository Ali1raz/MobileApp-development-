<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function profile(Request $req)
    {
        $user = $req->user();

        return response()->json([
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'registration_number' => $user->role === User::ROLE_STUDENT ? $user->registration_number : null,
            'created_at' => $user->created_at,
        ]);
    }
}
