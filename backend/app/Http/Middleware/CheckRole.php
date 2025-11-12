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
     * @param  mixed  ...$roles
     * @return mixed
     */
    public function handle($request, Closure $next, ...$roles)
    {
        if (!Auth::check()) {
            return response()->json(['error' => 'Authentication required'], 401);
        }

        $user = Auth::user();

        // Cek apakah role user ada di dalam daftar $roles yang diizinkan
        if (!in_array($user->role, $roles)) {
            return response()->json(['error' => 'Unauthorized. Insufficient permissions.'], 403);
        }

        return $next($request);
    }
}