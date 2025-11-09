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

// --- PERBAIKANNYA DI SINI ---
// Hapus tanda '//' dari dua baris di bawah ini
$app->withFacades(); 
$app->withEloquent(); 



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
    CorsMiddleware::class 
]);

/*
|--------------------------------------------------------------------------
| Register Route Middleware
|--------------------------------------------------------------------------
*/
$app->routeMiddleware([
    'auth' => App\Http\Middleware\Authenticate::class,
]);


/*
|--------------------------------------------------------------------------
| Register Service Providers
|--------------------------------------------------------------------------
*/

$app->register(App\Providers\AuthServiceProvider::class);


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