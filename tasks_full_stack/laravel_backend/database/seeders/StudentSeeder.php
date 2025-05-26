<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class StudentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $students = [
            ['name' => "Alice Smith", 'email' => 'alice@example.com'],
            ['name' => "Bob Johnson", 'email' => 'bob2@example.com'],
            ['name' => "Charlie Brown", 'email' => 'charlie@example.com'],
            ['name' => "Ahmad", 'email' => 'ahmad@example.com'],
            ['name' => "Abbass", 'email' => 'abbass@example.com'],
            ['name' => "Ijaz", 'email' => 'ijaz@example.com'],
            ['name' => "Hassan", 'email' => 'hassan@example.com'],
            ['name' => 'Sponge Bob', 'email' => 'sponge@example.com'],
            ['name' => 'David Wilson', 'email' => 'david@test.com'],
            ['name' => 'Eva Davis', 'email' => 'eva@test.com'],
            ['name' => 'Bilal', 'email' => 'bilal@example.com'],
        ];

        // Create predefined students
        foreach ($students as $index => $student) {
            User::factory()->create([
                'name' => $student['name'],
                'email' => $student['email'],
                'registration_number' => 'STU' . str_pad($index + 1, 3, '0', STR_PAD_LEFT),
                'password' => bcrypt('password1234'),
            ]);
        }

        // Create additional random students
        $startIndex = count($students);
        User::factory()
            ->count(20)
            ->sequence(fn($sequence) => [
                'registration_number' => 'STU' . str_pad($startIndex + $sequence->index + 1, 3, '0', STR_PAD_LEFT)
            ])
            ->create();
    }
}
