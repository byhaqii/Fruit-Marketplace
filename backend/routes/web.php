<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| File ini dimuat OLEH bootstrap/app.php di dalam grup 'App\Http\Controllers'
|
*/

$router->get('/', function () use ($router) {
    return $router->app->version();
});

// ==========================================================
// RUTE PUBLIK (Bisa diakses siapa saja, tidak perlu token)
// ==========================================================
$router->post('/auth/login', 'AuthController@login');
$router->post('/auth/register', 'AuthController@register');

$router->get('/produk', 'ProdukController@index');
$router->get('/produk/{id}', 'ProdukController@show');
$router->get('/produk/{id}/reviews', 'ReviewController@index'); // Menampilkan review itu publik


// ==========================================================
// RUTE KHUSUS WARGA (Harus login, middleware 'auth')
// ==========================================================
// Rute di grup ini bisa diakses oleh 'warga' DAN 'admin'
$router->group(['middleware' => 'auth'], function () use ($router) {
    
    $router->post('/auth/logout', 'AuthController@logout');
    
    // Asumsi Anda punya method 'profile' di UserController
    $router->get('/profile', 'UserController@profile'); 

    // Rute Transaksi (Warga)
    $router->get('/transaksi', 'TransaksiController@getUserTransactions'); 
    $router->post('/transaksi/checkout', 'TransaksiController@store');      
    $router->get('/transaksi/{id}', 'TransaksiController@show');          
    
    // Rute Review (Warga)
    $router->post('/produk/{id}/reviews', 'ReviewController@store'); // Hanya user login yg bisa post review
});

// ==========================================================
// RUTE ADMIN / RT RW (Harus login + role 'admin')
// ==========================================================
// Middleware 'role:admin' akan memblokir 'warga' biasa
$router->group(['middleware' => ['auth', 'role:admin']], function () use ($router) {
    
    // Manajemen Produk (Admin / RT RW)
    $router->post('/produk', 'ProdukController@store');
    $router->put('/produk/{id}', 'ProdukController@update'); // <-- DIPERBAIKI: Menggunakan PUT
    $router->delete('/produk/{id}', 'ProdukController@destroy');

    // Manajemen Pengguna (Admin)
    $router->get('/users', 'UserController@index');
    $router->get('/users/{id}', 'UserController@show');
    $router->post('/users', 'UserController@store');
    $router->put('/users/{id}', 'UserController@update'); // <-- DIPERBAIKI: Menggunakan PUT
    $router->delete('/users/{id}', 'UserController@destroy');

    // Manajemen Iuran (Admin / Bendahara)
    $router->get('/iuran', 'IuranController@index');
    $router->get('/iuran/{id}', 'IuranController@show');
    $router->post('/iuran', 'IuranController@store');
    $router->put('/iuran/{id}', 'IuranController@update'); // <-- DIPERBAIKI: Menggunakan PUT
    $router->delete('/iuran/{id}', 'IuranController@destroy');

    // Rute Manajemen Warga (Admin / RT RW)
    $router->get('/warga', 'WargaController@index');
    $router->post('/warga', 'WargaController@store');
    $router->get('/warga/{id}', 'WargaController@show');
    $router->put('/warga/{id}', 'WargaController@update');
    $router->delete('/warga/{id}', 'WargaController@destroy');
    
    // Rute Laporan Transaksi (Admin)
    $router->get('/transaksi/all', 'TransaksiController@index');
});

// <-- Kurung kurawal '}' yang ekstra di file Anda sudah dihapus.