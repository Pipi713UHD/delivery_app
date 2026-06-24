<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    exit;
}

require_once __DIR__ . "/../controllers/direccioncontroller.php";

$controller = new DireccionController();

$accion = $_GET["accion"] ?? "";

switch ($accion) {
    case "listar_por_cliente":
        $controller->listarPorCliente();
        break;

    case "obtener":
        $controller->obtener();
        break;

    case "crear":
        $controller->crear();
        break;

    case "editar":
        $controller->editar();
        break;

    case "marcar_principal":
        $controller->marcarPrincipal();
        break;

    case "eliminar":
        $controller->eliminar();
        break;

    default:
        echo json_encode([
            "status" => false,
            "message" => "Ruta de direcciones no válida"
        ]);
        break;
}
