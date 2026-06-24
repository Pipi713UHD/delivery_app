<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") { exit; }
require_once __DIR__ . "/../controllers/usuariocontroller.php";
$controller = new UsuarioController();
$accion = $_GET["accion"] ?? "";
switch ($accion) {
    case "listar": $controller->listar(); break;
    case "cambiar_estado": $controller->cambiarEstado(); break;
    case "crear_repartidor":
    $controller->crearRepartidor();
    break;
    default: echo json_encode(["status" => false, "message" => "Ruta de usuarios no válida"]); break;

}


