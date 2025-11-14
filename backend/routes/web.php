<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
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
// RUTE ADMIN (Harus login + role 'admin')
// DIPINDAHKAN KE ATAS AGAR /transaksi/all DIDETEKSI DULUAN
// ==========================================================
$router->group(['middleware' => ['auth', 'role:admin']], function () use ($router) {
    
    // Manajemen Pengguna (Admin)
    $router->get('/users', 'UserController@index');
    $router->get('/users/{id}', 'UserController@show');
    $router->post('/users', 'UserController@store');
    $router->put('/users/{id}', 'UserController@update'); 
    $router->delete('/users/{id}', 'UserController@destroy');

    // Rute Laporan Transaksi (Admin)
    $router->get('/transaksi/all', 'TransaksiController@index'); // Rute statis
});


// ==========================================================
// RUTE PENJUAL (Harus login + role 'admin' ATAU 'penjual')
// ==========================================================
$router->group(['middleware' => ['auth', 'role:admin,penjual']], function () use ($router) {
    
    // Manajemen Produk (Admin / Penjual)
    $router->post('/produk', 'ProdukController@store');
    $router->put('/produk/{id}', 'ProdukController@update'); 
    $router->delete('/produk/{id}', 'ProdukController@destroy');

});


// ==========================================================
// RUTE TERAUTENTIKASI (PEMBELI, PENJUAL, ADMIN)
// ==========================================================
$router->group(['middleware' => 'auth'], function () use ($router) {
    
    $router->post('/auth/logout', 'AuthController@logout');
    
    // Mengarah ke ProfileController baru
    $router->get('/profile', 'ProfileController@show');
    $router->put('/profile', 'ProfileController@update'); // Rute untuk update profile

    // Rute Transaksi (Pembeli)
    $router->get('/transaksi', 'TransaksiController@getUserTransactions'); 
    $router->post('/transaksi/checkout', 'TransaksiController@store');      
    $router->get('/transaksi/{id}', 'TransaksiController@show'); // Rute variabel
    
    // Rute Review (Pembeli)
    $router->post('/produk/{id}/reviews', 'ReviewController@store'); // Hanya user login yg bisa post review
});