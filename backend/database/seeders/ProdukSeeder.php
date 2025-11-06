<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
// Asumsikan model Produk ada di App\Models\Produk
// Asumsikan model Warga ada di App\Models\Warga
use App\Models\Produk;
use App\Models\Warga;

class ProdukSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run(): void
    {
        // Ambil ID Warga Biasa yang menjual
        $wargaPenjual = Warga::where('nama', 'Warga Biasa')->first();

        if ($wargaPenjual) {
            $produkData = [
                [
                    'warga_id' => $wargaPenjual->id,
                    'nama_produk' => 'Keripik Singkong Pedas',
                    'deskripsi' => 'Keripik singkong buatan rumahan, renyah dan pedas.',
                    'harga' => 12000.00,
                    'stok' => 50,
                    'kategori' => 'Makanan Ringan',
                    'status_jual' => 'Tersedia',
                ],
                [
                    'warga_id' => $wargaPenjual->id,
                    'nama_produk' => 'Sayur Bayam Segar',
                    'deskripsi' => 'Bayam organik dipanen pagi hari dari kebun sendiri.',
                    'harga' => 7500.00,
                    'stok' => 20,
                    'kategori' => 'Sayuran',
                    'status_jual' => 'Tersedia',
                ],
                [
                    'warga_id' => $wargaPenjual->id,
                    'nama_produk' => 'Jasa Servis Komputer',
                    'deskripsi' => 'Menerima servis laptop dan komputer, instalasi software dan hardware.',
                    'harga' => 150000.00,
                    'stok' => 999, 
                    'kategori' => 'Jasa',
                    'status_jual' => 'Tersedia',
                ],
            ];

            foreach ($produkData as $produk) {
                Produk::firstOrCreate(['nama_produk' => $produk['nama_produk']], $produk);
            }
        }
    }
}