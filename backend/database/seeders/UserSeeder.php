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
        $users = [
            [
                'name' => 'Admin Sistem',
                'email' => 'admin@jawarapintar.com',
                'role' => 'admin',
                'password' => Hash::make('password'),
                'api_token' => Str::random(60),
            ],
            [
                'name' => 'Ketua RT 01',
                'email' => 'ketuart@jawarapintar.com',
                'role' => 'ketua_rt',
                'password' => Hash::make('password'),
                'api_token' => Str::random(60),
            ],
            [
                'name' => 'Bendahara RT',
                'email' => 'bendahara@jawarapintar.com',
                'role' => 'bendahara',
                'password' => Hash::make('password'),
                'api_token' => Str::random(60),
            ],
            [
                'name' => 'Sekretaris RT',
                'email' => 'sekretaris@jawarapintar.com',
                'role' => 'sekretaris',
                'password' => Hash::make('password'),
                'api_token' => Str::random(60),
            ],
            [
                'name' => 'Warga Biasa',
                'email' => 'warga@jawarapintar.com',
                'role' => 'warga',
                'password' => Hash::make('password'),
                'api_token' => Str::random(60),
            ],
        ];

        foreach ($users as $user) {
            User::firstOrCreate(['email' => $user['email']], $user);
        }
    }
}