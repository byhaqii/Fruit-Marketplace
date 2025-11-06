<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
// Asumsikan model Iuran ada di App\Models\Iuran
use App\Models\Iuran; 

class IuranSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run(): void
    {
        $iuranData = [
            [
                'nama_iuran' => 'Iuran Kebersihan Bulanan',
                'deskripsi' => 'Iuran rutin untuk operasional kebersihan lingkungan RT.',
                'jumlah' => 25000.00,
                'periode' => 'Bulanan',
                'is_aktif' => true,
            ],
            [
                'nama_iuran' => 'Iuran Keamanan Bulanan',
                'deskripsi' => 'Iuran rutin untuk biaya keamanan (pos ronda, petugas).',
                'jumlah' => 35000.00,
                'periode' => 'Bulanan',
                'is_aktif' => true,
            ],
            [
                'nama_iuran' => 'Dana Sosial Insidental',
                'deskripsi' => 'Dana yang dikumpulkan untuk kejadian mendesak (kematian, sakit parah).',
                'jumlah' => 50000.00,
                'periode' => 'Satu Kali',
                'is_aktif' => true,
            ],
        ];

        foreach ($iuranData as $iuran) {
            Iuran::firstOrCreate(['nama_iuran' => $iuran['nama_iuran']], $iuran);
        }
    }
}