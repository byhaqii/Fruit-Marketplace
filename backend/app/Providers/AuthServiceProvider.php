<?php

namespace App\Providers;

use App\Models\User; // <-- TAMBAHKAN IMPORT MODEL USER
use Illuminate\Support\ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Boot the authentication services for the application.
     *
     * @return void
     */
    public function boot()
    {
        // --- HAPUS TANDA KOMENTAR (//) DARI BLOK DI BAWAH INI ---
        
        // Di sini Anda dapat menentukan bagaimana Anda ingin pengguna diautentikasi
        // untuk aplikasi Lumen Anda. Layanan '$this->app['auth']' memberi Anda
        // akses untuk memeriksa pengguna melalui stateless means atau user provider.
        
        $this->app['auth']->viaRequest('api', function ($request) {
            // Logika ini akan secara otomatis memeriksa 'api_token' 
            // di query string ATAU 'Bearer Token' di header Authorization
            
            if ($request->input('api_token')) {
                return User::where('api_token', $request->input('api_token'))->first();
            }

            // Jika menggunakan Bearer Token (dari Postman/Flutter)
            if ($request->bearerToken()) {
                 return User::where('api_token', $request->bearerToken())->first();
            }
        });
        
        // --- AKHIR BLOK YANG DI-UNCOMMENT ---
    }
}