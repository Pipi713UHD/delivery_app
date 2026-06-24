<?php

header("Content-Type: application/json; charset=UTF-8");

echo json_encode([
    "status" => true,
    "message" => "API Delivery App funcionando correctamente",
    "version" => "1.0.0"
]);