<?php

function responseJson($status, $message, $data = null, $code = 200)
{
    http_response_code($code);

    echo json_encode([
        "status" => $status,
        "message" => $message,
        "data" => $data
    ], JSON_UNESCAPED_UNICODE);

    exit;
}