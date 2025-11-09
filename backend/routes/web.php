<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
*/

$router->get('/', function () use ($router) {
    return $router->app->version();
});

// Hapus grup namespace dari sini (sudah ada di bootstrap/app.php)
    
// Auth Routes
$router->post('/auth/login', 'AuthController@login');
$router->post('/auth/register', 'AuthController@register'); // <-- TAMBAHKAN BARIS INI

// Protected Routes (Perlu token untuk akses)
$router->group(['middleware' => 'auth'], function () use ($router) {
    $router->post('/auth/logout', 'AuthController@logout');
    
    $router->get('/user/profile', function (\Illuminate\Http\Request $request) {
        return response()->json($request->user());
    });
    
    // Route untuk modul-modul lain akan ditambahkan di sini
});