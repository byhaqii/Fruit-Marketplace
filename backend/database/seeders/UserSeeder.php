<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run(): void
    {
        // --- PERUBAHAN DI SINI ---
        // Menyesuaikan data user dengan role baru
        $users = [
            [
                'name' => 'Admin Sistem',
                'email' => 'admin@jawarapintar.com',
                'role' => 'admin', // Role baru
                'password' => Hash::make('password'),
                'api_token' => Str::random(60),
            ],
            [
                'name' => 'Penjual Buah',
                'email' => 'penjual@jawarapintar.com',
                'role' => 'penjual', // Role baru
                'password' => Hash::make('password'),
                'api_token' => Str::random(60),
            ],
            [
                'name' => 'Pembeli Biasa',
                'email' => 'pembeli@jawarapintar.com',
                'role' => 'pembeli', // Role baru
                'password' => Hash::make('password'),
                'api_token' => Str::random(60),
            ],
        ];
        // --- AKHIR PERUBAHAN ---

        foreach ($users as $user) {
            User::firstOrCreate(['email' => $user['email']], $user);
        }
    }
}