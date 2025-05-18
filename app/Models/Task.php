<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Task extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'due_date',
    ];

    public function students()
    {
        return $this->belongsToMany(User::class, 'student_task', 'task_id', 'registration_number', 'id', 'registration_number')
            ->withPivot('is_completed')
            ->withTimestamps();
    }
}
