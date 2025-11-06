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

$router->group(['namespace' => 'App\Http\Controllers'], function ($router) {
    
    // Auth Routes
    $router->post('/auth/login', 'AuthController@login');

    // Protected Routes (Perlu token untuk akses)
    $router->group(['middleware' => 'auth'], function () use ($router) {
        $router->post('/auth/logout', 'AuthController@logout');
        
        // Contoh endpoint untuk mendapatkan profil pengguna yang sedang login
        $router->get('/user/profile', function (\Illuminate\Http\Request $request) {
            return response()->json($request->user());
        });
        
        // Route untuk modul-modul lain akan ditambahkan di sini
    });
});