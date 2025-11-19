<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Produk;
use App\Models\User; // Ganti Warga menjadi User

class ProdukSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run(): void
    {
        // --- PERUBAHAN LOGIKA SEEDER ---
        // Ambil User Penjual (dari UserSeeder yang kita buat di langkah sebelumnya)
        $userPenjual = User::where('role', 'penjual')->first();

        if ($userPenjual) {
            $produkData = [
                [
                    'user_id' => $userPenjual->id, // Ganti warga_id menjadi user_id
                    'nama_produk' => 'Keripik Singkong Pedas',
                    'deskripsi' => 'Keripik singkong buatan rumahan, renyah dan pedas.',
                    'harga' => 12000.00,
                    'stok' => 50,
                    'kategori' => 'Makanan Ringan',
                    'status_jual' => 'Tersedia',
                ],
                [
                    'user_id' => $userPenjual->id, // Ganti warga_id menjadi user_id
                    'nama_produk' => 'Sayur Bayam Segar',
                    'deskripsi' => 'Bayam organik dipanen pagi hari dari kebun sendiri.',
                    'harga' => 7500.00,
                    'stok' => 20,
                    'kategori' => 'Sayuran',
                    'status_jual' => 'Tersedia',
                ],
            ];
            // --- AKHIR PERUBAHAN ---

            foreach ($produkData as $produk) {
                Produk::firstOrCreate(['nama_produk' => $produk['nama_produk']], $produk);
            }
        }
    }
}