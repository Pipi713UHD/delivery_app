<?php

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    exit;
}

require_once __DIR__ . "/../controllers/pedidocontroller.php";

$controller = new PedidoController();

$accion = $_GET["accion"] ?? "";

switch ($accion) {

    case "crear":
        if ($_SERVER["REQUEST_METHOD"] !== "POST") {
            echo json_encode([
                "status" => false,
                "message" => "Método no permitido. Usa POST."
            ]);
            exit;
        }

        $controller->crear();
        break;

    case "listar_por_cliente":
        $controller->listarPorCliente();
        break;

    case "detalle":
        $controller->detalle();
        break;

    case "listar_disponibles_repartidor":
        $controller->listarDisponiblesRepartidor();
        break;

    case "aceptar_repartidor":
        if ($_SERVER["REQUEST_METHOD"] !== "POST") {
            echo json_encode([
                "status" => false,
                "message" => "Método no permitido. Usa POST."
            ]);
            exit;
        }

        $controller->aceptarPedidoRepartidor();
        break;

    case "listar_por_repartidor":
        $controller->listarPorRepartidor();
        break;

    case "cambiar_estado_repartidor":
        if ($_SERVER["REQUEST_METHOD"] !== "POST") {
            echo json_encode([
                "status" => false,
                "message" => "Método no permitido. Usa POST."
            ]);
            exit;
        }

        $controller->cambiarEstadoRepartidor();
        break;

    case "listar_por_restaurante":
        $controller->listarPorRestaurante();
        break;

    case "listar_admin":
        $controller->listarAdmin();
        break;

    case "cambiar_estado_admin":
        if ($_SERVER["REQUEST_METHOD"] !== "POST") {
            echo json_encode(["status" => false, "message" => "Método no permitido. Usa POST."]);
            exit;
        }
        $controller->cambiarEstadoAdmin();
        break;

    case "cambiar_estado_restaurante":
        if ($_SERVER["REQUEST_METHOD"] !== "POST") {
            echo json_encode([
                "status" => false,
                "message" => "Método no permitido. Usa POST."
            ]);
            exit;
        }

        $controller->cambiarEstadoRestaurante();
        break;

    default:
        echo json_encode([
            "status" => false,
            "message" => "Ruta de pedidos no válida"
        ]);
        break;
}