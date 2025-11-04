<?php
// ...existing code...
// Simple route map for reference; adapt to your framework (Laravel routes/web.php or routes/api.php)
return [
    ['method' => 'POST', 'uri' => '/auth/login', 'action' => 'AuthController@login'],
    ['method' => 'GET', 'uri' => '/warga', 'action' => 'WargaController@index'],
    // add more routes here
];
?>