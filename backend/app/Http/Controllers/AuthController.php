<?php
namespace App\Http\Controllers;

use App\Helpers\ResponseHelper; // Menggunakan ResponseHelper

class AuthController
{
    /**
     * Menangani permintaan login dan mengembalikan token dan role.
     * Menggunakan mock logic karena tidak ada database/framework lengkap.
     */
    public function login($request) 
    {
        // Asumsi $request memiliki properti email dan password.
        $email = $request['email'] ?? '';
        $password = $request['password'] ?? '';

        // Mock autentikasi dan penentuan role.
        // Role akan ditentukan dari bagian pertama email untuk demonstrasi.
        $role = 'Warga';
        if (strpos($email, 'admin') !== false) {
            $role = 'Admin';
        } elseif (strpos($email, 'ketua') !== false) {
            $role = 'Ketua RT/RW';
        } elseif (strpos($email, 'bendahara') !== false) {
            $role = 'Bendahara';
        } elseif (strpos($email, 'sekretaris') !== false) {
            $role = 'Sekretaris';
        } 
        
        // Asumsi login berhasil jika email dan password tidak kosong
        if (empty($email) || empty($password)) {
            return ResponseHelper::error('Email atau password tidak boleh kosong', 400);
        }

        // Generate mock token
        $token = 'mock_token_' . strtolower(str_replace(' ', '_', $role));

        $data = [
            'user' => ['id' => 1, 'email' => $email, 'name' => $role],
            'token' => $token,
            'role' => $role,
        ];

        return ResponseHelper::success($data, 'Login berhasil', 200);
    }
}