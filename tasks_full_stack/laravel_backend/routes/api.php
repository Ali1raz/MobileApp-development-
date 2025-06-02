<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Student\StudentController;
use App\Http\Controllers\Task\TaskController;
use App\Http\Controllers\UserController;
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
    Route::post('/logout', [AuthenticatedSessionController::class, 'destroy']);

    Route::get('/dashboard', [AdminController::class, 'dashboard']);

    Route::get('/pending-registrations', [AdminController::class, 'getPendingRegistrations']);
    Route::post('/approve-registration/{id}', [AdminController::class, 'approveRegistration']);
    Route::post('/reject-registration/{id}', [AdminController::class, 'rejectRegistration']);


    Route::post('register-student', [AdminController::class, 'registerStudent']);
    Route::get('/students', [AdminController::class, 'listStudents']);
    Route::get('/students/{registration_number}', [AdminController::class, 'viewStudent']);

    Route::put('/students/{registration_number}', [AdminController::class, 'updateStudent']);
    Route::delete('/students/{registration_number}', [AdminController::class, 'deleteStudent']);

    Route::get('/profile', [UserController::class, 'profile']);

    Route::put('/profile', [UserController::class, 'updateProfile']);

    Route::get('/tasks', [TaskController::class, 'index']);
    Route::post('/tasks', [TaskController::class, 'createTask']);
    Route::post('/tasks/{taskId}/progress', [TaskController::class, 'taskProgress']);
    Route::delete('/tasks/{taskId}', [TaskController::class, 'deleteTask']);
    Route::put('/tasks/{taskId}', [TaskController::class, 'updateTask']);
});

Route::post('/student/login', [StudentController::class, 'store']);
Route::post('/student/register', [StudentController::class, 'register']);


Route::middleware(['auth:sanctum', 'role:student'])->prefix('student')->group(function () {
    Route::post('/logout', [AuthenticatedSessionController::class, 'destroy']);
    Route::get('/dashboard', [StudentController::class, 'dashboard']);

    Route::get('/profile', [UserController::class, 'profile']);
    Route::put('/profile', [UserController::class, 'updateProfile']);

    Route::get('/tasks', [TaskController::class, 'index']);
    Route::post('/tasks/{taskId}/complete', [TaskController::class, 'markComplete']);
});

Route::post('/logout', [AuthenticatedSessionController::class, 'destroy'])
    ->middleware('auth:sanctum')
    ->name('logout');
