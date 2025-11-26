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
// 1. RUTE PUBLIK (Tanpa Token)
// ==========================================================
$router->post('/auth/login', 'AuthController@login');
$router->post('/auth/register', 'AuthController@register');

// Produk & Review bisa dilihat publik
$router->get('/produk', 'ProdukController@index');
$router->get('/produk/{id}', 'ProdukController@show');
$router->get('/produk/{id}/reviews', 'ReviewController@index');

$router->get('/storage/{filename}', function ($filename) {
    $path = base_path('public/storage/' . $filename);
    if (!file_exists($path)) return response()->json(['message' => 'Not found'], 404);
    return response(file_get_contents($path), 200)->header("Content-Type", mime_content_type($path));
});


// ==========================================================
// 2. RUTE ADMIN (Role: admin)
// ==========================================================
$router->group(['middleware' => ['auth', 'role:admin']], function () use ($router) {
    
    // Manajemen User
    $router->get('/users', 'UserController@index');
    $router->get('/users/{id}', 'UserController@show');
    $router->post('/users', 'UserController@store');
    $router->put('/users/{id}', 'UserController@update');
    $router->delete('/users/{id}', 'UserController@destroy');

    // Laporan Semua Transaksi
    $router->get('/transaksi/all', 'TransaksiController@index');
    // Log Aktivitas Sistem
    $router->get('/admin/activities', 'NotificationController@getActivities');
    
    // Update Status Withdraw
    $router->put('/withdraw/{id}', 'WithdrawController@updateStatus');
});


// ==========================================================
// 3. RUTE PENJUAL (Role: admin, penjual)
// ==========================================================
$router->group(['middleware' => ['auth', 'role:admin,penjual']], function () use ($router) {

    // Manajemen Produk (CRUD)
    $router->post('/produk', 'ProdukController@store');
    $router->put('/produk/{id}', 'ProdukController@update');
    $router->delete('/produk/{id}', 'ProdukController@destroy');
    
    // Manajemen Pesanan Masuk
    $router->get('/transaksi/masuk', 'TransaksiController@getSellerTransactions');
    $router->put('/transaksi/{id}/update-status', 'TransaksiController@updateStatusBySeller');
});


// ==========================================================
// 4. RUTE TERAUTENTIKASI UMUM (Semua Role)
// ==========================================================
$router->group(['middleware' => 'auth'], function () use ($router) {

    $router->post('/auth/logout', 'AuthController@logout');
    
    // Notifikasi
    $router->get('/notifications', 'NotificationController@index');
    $router->post('/notifications/read-all', 'NotificationController@markAllRead');

    // Profil Pengguna
    $router->get('/profile', 'ProfileController@show');
    $router->put('/profile', 'ProfileController@update');

    // Transaksi (Sisi Pembeli)
    $router->get('/transaksi', 'TransaksiController@getUserTransactions');
    $router->post('/transaksi/checkout', 'TransaksiController@store');
    $router->get('/transaksi/{id}', 'TransaksiController@show');
    
    // Aksi Pembeli pada Pesanan
    $router->put('/transaksi/{id}/cancel', 'TransaksiController@cancelOrder');
    $router->put('/transaksi/{id}/terima', 'TransaksiController@markAsReceived');

    // Review Produk
    $router->post('/produk/{id}/reviews', 'ReviewController@store');
    
    // Withdraw / Penarikan Saldo
    $router->post('/withdraw', 'WithdrawController@store');
    $router->get('/withdraw', 'WithdrawController@index');
});


// ==========================================================
// 5. HELPER ROUTES (Akses Gambar Storage)
// ==========================================================
$router->get('/storage/{filename}', function ($filename) {
    $path = base_path('public/storage/' . $filename);
    if (!file_exists($path)) {
        return response()->json(['message' => 'Image not found'], 404);
    }
    $file = file_get_contents($path);
    $type = mime_content_type($path);
    return response($file, 200)->header("Content-Type", $type);
});

$router->get('/storage/profiles/{filename}', function ($filename) {
    $path = base_path('public/storage/profiles/' . $filename);
    if (!file_exists($path)) {
        return response()->json(['message' => 'Image not found'], 404);
    }
    $file = file_get_contents($path);
    $type = mime_content_type($path);
    return response($file, 200)->header("Content-Type", $type);
});