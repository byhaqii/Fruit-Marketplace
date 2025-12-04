<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string|array  $roles
     * @return mixed
     */
    public function handle($request, Closure $next, ...$roles)
    {
        if (!Auth::check()) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $user = Auth::user();

        // Ambil peran pengguna saat ini
        $userRole = strtolower(trim($user->role)); // <--- PERBAIKAN: Bersihkan dan ubah ke huruf kecil

        // Ubah peran yang disyaratkan oleh rute juga ke huruf kecil (untuk konsistensi)
        $requiredRoles = array_map('strtolower', $roles);

        // Periksa apakah peran pengguna ada di dalam daftar peran yang diizinkan
        if (!in_array($userRole, $requiredRoles)) {
            return response()->json(['message' => 'Forbidden (Role mismatch)'], 403);
        }

        return $next($request);
    }
}