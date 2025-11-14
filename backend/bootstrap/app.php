<?php

require_once __DIR__.'/../vendor/autoload.php';

// Menggunakan middleware CORS kustom Anda
use App\Http\Middleware\CorsMiddleware; 
use Illuminate\Database\Eloquent\Factories\HasFactory;


(new Laravel\Lumen\Bootstrap\LoadEnvironmentVariables(
    dirname(__DIR__)
))->bootstrap();

date_default_timezone_set(env('APP_TIMEZONE', 'UTC'));

/*
|--------------------------------------------------------------------------
| Create The Application
|--------------------------------------------------------------------------
*/

$app = new Laravel\Lumen\Application(
    dirname(__DIR__)
);

// --- PERBAIKAN ERROR 500 ---
$app->withFacades(); 
$app->withEloquent(); 

// --- TAMBAHKAN ALIAS UNTUK QR CODE ---
$app->alias('QrCode', SimpleSoftwareIO\QrCode\Facades\QrCode::class);
// ------------------------------------


/*
|--------------------------------------------------------------------------
| Register Container Bindings
|--------------------------------------------------------------------------
*/

$app->singleton(
    Illuminate\Contracts\Debug\ExceptionHandler::class,
    App\Exceptions\Handler::class
);

$app->singleton(
    Illuminate\Contracts\Console\Kernel::class,
    App\Console\Kernel::class
);

/*
|--------------------------------------------------------------------------
| Register Config Files
|--------------------------------------------------------------------------
*/

$app->configure('database'); 

/*
|--------------------------------------------------------------------------
| Register Middleware
|--------------------------------------------------------------------------
*/

$app->middleware([
    App\Http\Middleware\CorsMiddleware::class
]);

/*
|--------------------------------------------------------------------------
| Register Route Middleware
|--------------------------------------------------------------------------
*/
$app->routeMiddleware([
    'auth' => App\Http\Middleware\Authenticate::class,
    'role' => App\Http\Middleware\CheckRole::class
]);


/*
|--------------------------------------------------------------------------
| Register Service Providers
|--------------------------------------------------------------------------
*/

$app->register(App\Providers\AuthServiceProvider::class);
$app->register(SimpleSoftwareIO\QrCode\QrCodeServiceProvider::class); // Ini sudah benar


/*
|--------------------------------------------------------------------------
| Load The Application Routes
|--------------------------------------------------------------------------
*/

$app->router->group([
    'namespace' => 'App\Http\Controllers',
], function ($router) {
    require __DIR__.'/../routes/web.php'; 
});


return $app;