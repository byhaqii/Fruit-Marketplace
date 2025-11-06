<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
// Asumsikan model Warga ada di App\Models\Warga
use App\Models\Warga; 

class WargaSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run(): void
    {
        // Ambil data User yang sudah dibuat di UserSeeder
        $wargaUser = User::where('email', 'warga@jawarapintar.com')->first();
        $ketuaRtUser = User::where('email', 'ketuart@jawarapintar.com')->first();
        $sekretarisUser = User::where('email', 'sekretaris@jawarapintar.com')->first();

        $wargaData = [
            [
                'user_id' => $wargaUser->id ?? null,
                'nik' => '3201010101000001',
                'nama' => 'Warga Biasa',
                'tempat_lahir' => 'Jakarta',
                'tanggal_lahir' => '1990-01-01',
                'jenis_kelamin' => 'Laki-laki',
                'alamat' => 'Jalan Kebahagiaan No. 1',
                'status_keluarga' => 'Kepala Keluarga',
                'is_verified' => true,
            ],
            [
                'user_id' => $ketuaRtUser->id ?? null,
                'nik' => '3201010101000002',
                'nama' => 'Ketua RT Hebat',
                'tempat_lahir' => 'Bandung',
                'tanggal_lahir' => '1985-05-15',
                'jenis_kelamin' => 'Laki-laki',
                'alamat' => 'Jalan Pahlawan No. 10',
                'status_keluarga' => 'Kepala Keluarga',
                'is_verified' => true,
            ],
            [
                'user_id' => $sekretarisUser->id ?? null,
                'nik' => '3201010101000003',
                'nama' => 'Sekretaris Cekatan',
                'tempat_lahir' => 'Bogor',
                'tanggal_lahir' => '1995-12-20',
                'jenis_kelamin' => 'Perempuan',
                'alamat' => 'Jalan Setia Budi No. 5',
                'status_keluarga' => 'Istri',
                'is_verified' => true,
            ]
        ];

        foreach ($wargaData as $data) {
            Warga::firstOrCreate(['nik' => $data['nik']], $data);
        }
        
        // Opsional: Buat 10 data Warga dummy menggunakan factory jika tersedia
        // Warga::factory(10)->create();
    }
}