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

// Auth Routes (Publik)
$router->post('/auth/login', 'AuthController@login');
$router->post('/auth/register', 'AuthController@register');

// Rute Produk (Publik - Warga bisa melihat)
$router->get('/produk', 'ProdukController@index');
$router->get('/produk/{id}', 'ProdukController@show');


// Protected Routes (Perlu token untuk akses)
$router->group(['middleware' => 'auth'], function () use ($router) {
    $router->post('/auth/logout', 'AuthController@logout');
    $router->get('/user/profile', function (\Illuminate\Http\Request $request) {
        return response()->json($request->user());
    });
    
    // Manajemen Produk (Hanya RT/RW & Sekretaris)
    $router->post('/produk', 'ProdukController@store');
    $router->post('/produk/{id}', 'ProdukController@update');
    $router->delete('/produk/{id}', 'ProdukController@destroy');

    // Manajemen Pengguna (Hanya Admin)
    $router->get('/users', 'UserController@index');
    $router->get('/users/{id}', 'UserController@show');
    $router->post('/users', 'UserController@store');
    $router->post('/users/{id}', 'UserController@update');
    $router->delete('/users/{id}', 'UserController@destroy');

    // Manajemen Iuran (Hanya Admin)
    $router->get('/iuran', 'IuranController@index');
    $router->get('/iuran/{id}', 'IuranController@show');
    $router->post('/iuran', 'IuranController@store');
    $router->post('/iuran/{id}', 'IuranController@update');
    $router->delete('/iuran/{id}', 'IuranController@destroy');
});