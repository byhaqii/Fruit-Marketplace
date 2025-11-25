<?php

namespace App\Http\Middleware;

use Closure;

class CheckRole
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string  $role
     * @return mixed
     */
    public function handle($request, Closure $next, $role)
    {
        // User harus login
        if (!$request->user()) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        // Ubah string "admin,penjual" menjadi array ["admin", "penjual"]
        $allowedRoles = explode(',', $role);

        // Cek apakah role user ada di dalam daftar yang diizinkan
        if (!in_array($request->user()->role, $allowedRoles)) {
            return response()->json(['message' => 'Forbidden: Akses ditolak'], 403);
        }

        return $next($request);
    }
}