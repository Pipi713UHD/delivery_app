<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    exit;
}

require_once __DIR__ . "/../controllers/authcontroller.php";

$controller = new AuthController();

$accion = $_GET["accion"] ?? "";

switch ($accion) {
    case "login":
        $controller->login();
        break;

    case "registrar":
        $controller->registrar();
        break;

    default:
        echo json_encode([
            "status" => false,
            "message" => "Ruta de autenticación no válida"
        ]);
        break;
}