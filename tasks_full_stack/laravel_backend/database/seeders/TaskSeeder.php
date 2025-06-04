<?php

namespace Database\Seeders;

use App\Models\Task;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;

class TaskSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Get all student registration numbers
        $studentRegNumbers = User::where('role', 'student')
            ->pluck('registration_number')
            ->toArray();

        // Predefined tasks with various due dates
        $tasks = [
            [
                'title' => 'Past Due Assignment',
                'description' => 'This assignment was due last week',
                'due_date' => Carbon::now()->subDays(7),
                'assigned_to' => array_slice($studentRegNumbers, 0, 5) // First 5 students
            ],
            [
                'title' => 'Due Today Assignment',
                'description' => 'This assignment is due today!',
                'due_date' => Carbon::now(),
                'assigned_to' => array_slice($studentRegNumbers, 5, 5) // Next 5 students
            ],
            [
                'title' => 'Due Tomorrow Task',
                'description' => 'Complete this task by tomorrow',
                'due_date' => Carbon::now()->addDay(),
                'assigned_to' => array_slice($studentRegNumbers, 10, 5) // Another 5 students
            ],
            [
                'title' => 'Due in 3 Days',
                'description' => 'You have 3 days to complete this',
                'due_date' => Carbon::now()->addDays(3),
                'assigned_to' => array_slice($studentRegNumbers, 15, 5) // Another 5 students
            ],
            [
                'title' => 'Due Next Week',
                'description' => 'Long term assignment due next week',
                'due_date' => Carbon::now()->addWeek(),
                'assigned_to' => array_slice($studentRegNumbers, 20, 5) // Last 5 students
            ],
            [
                'title' => 'Future Task',
                'description' => 'This task is due in 2 weeks',
                'due_date' => Carbon::now()->addWeeks(2),
                'assigned_to' => array_slice($studentRegNumbers, 25, 5) // Next 5 students
            ],
        ];

        // Create tasks and assign to students
        foreach ($tasks as $taskData) {
            $task = Task::create([
                'title' => $taskData['title'],
                'description' => $taskData['description'],
                'due_date' => $taskData['due_date']
            ]);

            // Assign task to specified students
            foreach ($taskData['assigned_to'] as $regNumber) {
                $student = User::where('registration_number', $regNumber)->first();
                if ($student) {
                    $task->students()->attach($student->id, [
                        'registration_number' => $regNumber,
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }
            }
        }
    }
}
