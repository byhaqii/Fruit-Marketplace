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

// Pastikan grup namespace App\Http\Controllers sudah dihapus dari sini
// (karena sudah ada di bootstrap/app.php)

// Auth Routes
// Pastikan ini adalah 'post', bukan 'get'
$router->post('/auth/login', 'AuthController@login');

// Protected Routes
$router->group(['middleware' => 'auth'], function () use ($router) {
    $router->post('/auth/logout', 'AuthController@logout');
    $router->get('/user/profile', function (\Illuminate\Http\Request $request) {
        return response()->json($request->user());
    });
});