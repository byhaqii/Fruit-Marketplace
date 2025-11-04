<?php
namespace App\Helpers;

class ResponseHelper
{
    public static function success($data = null, $message = 'OK', $code = 200)
    {
        return [
            'code' => $code,
            'message' => $message,
            'data' => $data,
        ];
    }

    public static function error($message = 'Error', $code = 500)
    {
        return [
            'code' => $code,
            'message' => $message,
        ];
    }
}
