<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Student\StudentController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::post('/admin/login', [AuthenticatedSessionController::class, 'store']);

Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    // all routes for admin only
    Route::get('/dashboard', [AdminController::class, 'dashboard']);
    Route::post('register-student', [AdminController::class, 'registerStudent']);
    Route::get('/students', [AdminController::class, 'listStudents']);
});

Route::post('/student/login', [StudentController::class, 'store']);

Route::middleware(['auth:sanctum', 'role:student'])->prefix('student')->group(function () {
    // all routes for admin only
    Route::get('/dashboard', [StudentController::class, 'dashboard']);
});
