<?php

namespace App\Http\Middleware;

use Closure;

class CorsMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        // Mendapatkan response dari request. Jika ini adalah preflight OPTIONS,
        // response awal akan kosong.
        $response = $next($request);

        // Header yang dibutuhkan oleh Flutter/Browser
        $headers = [
            'Access-Control-Allow-Origin'      => '*', // Izinkan semua domain (Ganti dengan URL Flutter Anda jika ingin lebih aman)
            'Access-Control-Allow-Methods'     => 'POST, GET, OPTIONS, PUT, DELETE',
            'Access-Control-Allow-Headers'     => 'Content-Type, X-Auth-Token, Origin, Authorization',
        ];

        // Jika request adalah OPTIONS (Preflight), kembalikan respon 200 OK dengan headers CORS
        if ($request->isMethod('OPTIONS')) {
            return response('OK', 200)->withHeaders($headers);
        }

        // Jika response adalah instance dari Response (bukan JsonResponse), tambahkan headers
        if (method_exists($response, 'header')) {
            foreach ($headers as $key => $value) {
                $response->header($key, $value);
            }
        }

        return $response;
    }
}