
<?php

return [
    'default' => env('DB_CONNECTION', 'mysql'),
    'connections' => [
        'mysql' => [
            'driver'    => 'mysql',
            'host'      => env('DB_HOST', '127.0.0.1'),
            'port'      => env('DB_PORT', '3306'),
            'database'  => env('DB_DATABASE', 'lumen'), // Pastikan ini mengambil dari .env
            'username'  => env('DB_USERNAME', 'root'),  // Pastikan ini mengambil dari .env
            'password'  => env('DB_PASSWORD', ''),
            'charset'   => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
            'prefix'    => '',
            'strict'    => true,
            'engine'    => null,
        ],
        // Anda bisa menambahkan koneksi lain di sini
    ],
    'migrations' => 'migrations'
];