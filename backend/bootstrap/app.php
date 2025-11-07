<?php

require_once __DIR__.'/../vendor/autoload.php';

// --- IMPORTS YANG DIBUTUHKAN ---
// Menggunakan FQCN untuk middleware CORS kustom
use App\Http\Middleware\CorsMiddleware; 
use Illuminate\Database\Eloquent\Factories\HasFactory;
// --- END IMPORTS ---


(new Laravel\Lumen\Bootstrap\LoadEnvironmentVariables(
    dirname(__DIR__)
))->bootstrap();

date_default_timezone_set(env('APP_TIMEZONE', 'UTC'));

/*
|--------------------------------------------------------------------------
| Create The Application
|--------------------------------------------------------------------------
|
| Instansiasi harus terjadi sebelum semua method app->dipanggil
|
*/

$app = new Laravel\Lumen\Application(
    dirname(__DIR__)
);

// Panggil withEloquent di sini
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
|
| Middleware Global untuk semua request (termasuk CORS kustom)
|
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


return $app; // PENTING: Application instance harus di-return di akhir file