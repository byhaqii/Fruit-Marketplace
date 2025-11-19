<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Produk;
use App\Models\User;

class ProdukSeeder extends Seeder
{
    public function run(): void
    {
        $userPenjual = User::where('role', 'penjual')->first();

        if ($userPenjual) {
            $produkData = [
                [
                    'user_id' => $userPenjual->id,
                    'nama_produk' => 'Keripik Singkong Pedas',
                    'deskripsi' => 'Keripik singkong buatan rumahan, renyah dan pedas.',
                    'harga' => 12000.00,
                    'stok' => 50,
                    'kategori' => 'Makanan Ringan',
                    // UBAH DI SINI: Ganti 'Tersedia' jadi 'Aktif'
                    'status_jual' => 'Aktif', 
                ],
                [
                    'user_id' => $userPenjual->id,
                    'nama_produk' => 'Sayur Bayam Segar',
                    'deskripsi' => 'Bayam organik dipanen pagi hari dari kebun sendiri.',
                    'harga' => 7500.00,
                    'stok' => 20,
                    'kategori' => 'Sayuran',
                    // UBAH DI SINI: Ganti 'Tersedia' jadi 'Aktif'
                    'status_jual' => 'Aktif',
                ],
            ];

            foreach ($produkData as $produk) {
                Produk::firstOrCreate(['nama_produk' => $produk['nama_produk']], $produk);
            }
        }
    }
}