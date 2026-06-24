<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    exit;
}

require_once __DIR__ . "/../controllers/productocontroller.php";

$controller = new ProductoController();

$accion = $_GET["accion"] ?? "";

switch ($accion) {

    case "listar_por_restaurante":
        $controller->listarPorRestaurante();
        break;

    case "obtener":
        $controller->obtener();
        break;

    case "listar_admin":
        $controller->listarAdmin();
        break;

    case "crear":
        $controller->crear();
        break;

    case "editar":
        $controller->editar();
        break;

    case "eliminar":
        $controller->eliminar();
        break;

    default:
        echo json_encode([
            "status" => false,
            "message" => "Ruta de productos no válida"
        ]);
        break;
}