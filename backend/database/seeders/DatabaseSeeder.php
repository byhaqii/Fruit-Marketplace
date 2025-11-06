<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class, 
            WargaSeeder::class,
            IuranSeeder::class,
            ProdukSeeder::class,
        ]);
        
        // Seeder untuk Transaksi dan Reviews dapat ditambahkan di sini.
    }
}