<?php

require_once __DIR__ . "/../models/pedido.php";
require_once __DIR__ . "/../helpers/response.php";

class PedidoController
{
    public function crear()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!$data) {
            responseJson(false, "No se recibieron datos válidos", null, 400);
        }

        if (
            !isset($data["id_cliente"]) ||
            !isset($data["id_restaurante"]) ||
            !isset($data["id_direccion"]) ||
            !isset($data["productos"])
        ) {
            responseJson(false, "Faltan datos obligatorios", null, 400);
        }

        if (!is_array($data["productos"]) || count($data["productos"]) == 0) {
            responseJson(false, "El pedido debe tener al menos un producto", null, 400);
        }

        $model = new Pedido();
        $pedido = $model->crear($data);

        if (isset($pedido["error"])) {
            responseJson(false, $pedido["message"], null, 500);
        }

        responseJson(true, "Pedido creado correctamente", $pedido, 201);
    }

    public function listarPorCliente()
    {
        if (!isset($_GET["id_cliente"])) {
            responseJson(false, "El id_cliente es obligatorio", null, 400);
        }

        $id_cliente = intval($_GET["id_cliente"]);

        $model = new Pedido();
        $pedidos = $model->listarPorCliente($id_cliente);

        responseJson(true, "Pedidos encontrados", $pedidos);
    }

    public function detalle()
    {
        if (!isset($_GET["id_pedido"])) {
            responseJson(false, "El id_pedido es obligatorio", null, 400);
        }

        $id_pedido = intval($_GET["id_pedido"]);

        $model = new Pedido();
        $pedido = $model->obtenerDetalle($id_pedido);

        if (!$pedido) {
            responseJson(false, "Pedido no encontrado", null, 404);
        }

        responseJson(true, "Detalle del pedido encontrado", $pedido);
    }

    public function listarDisponiblesRepartidor()
{
    $model = new Pedido();
    $pedidos = $model->listarDisponiblesRepartidor();

    responseJson(true, "Pedidos disponibles encontrados", $pedidos);
}

public function aceptarPedidoRepartidor()
{
    $data = json_decode(file_get_contents("php://input"), true);

    if (!$data) {
        responseJson(false, "No se recibieron datos válidos", null, 400);
    }

    if (!isset($data["id_pedido"]) || !isset($data["id_repartidor"])) {
        responseJson(false, "Faltan datos obligatorios", null, 400);
    }

    $id_pedido = intval($data["id_pedido"]);
    $id_repartidor = intval($data["id_repartidor"]);

    $model = new Pedido();
    $resultado = $model->aceptarPedidoRepartidor($id_pedido, $id_repartidor);

    if (isset($resultado["error"])) {
        responseJson(false, $resultado["message"], null, 500);
    }

    responseJson(true, "Pedido aceptado correctamente", $resultado);
}

public function listarPorRepartidor()
{
    if (!isset($_GET["id_repartidor"])) {
        responseJson(false, "El id_repartidor es obligatorio", null, 400);
    }

    $id_repartidor = intval($_GET["id_repartidor"]);

    $model = new Pedido();
    $pedidos = $model->listarPorRepartidor($id_repartidor);

    responseJson(true, "Pedidos del repartidor encontrados", $pedidos);
}

public function cambiarEstadoRepartidor()
{
    $data = json_decode(file_get_contents("php://input"), true);

    if (!$data) {
        responseJson(false, "No se recibieron datos válidos", null, 400);
    }

    if (
        !isset($data["id_pedido"]) ||
        !isset($data["id_repartidor"]) ||
        !isset($data["id_estado_pedido"])
    ) {
        responseJson(false, "Faltan datos obligatorios", null, 400);
    }

    $id_pedido = intval($data["id_pedido"]);
    $id_repartidor = intval($data["id_repartidor"]);
    $id_estado_pedido = intval($data["id_estado_pedido"]);

    $model = new Pedido();
    $resultado = $model->cambiarEstadoRepartidor(
        $id_pedido,
        $id_repartidor,
        $id_estado_pedido
    );

    if (isset($resultado["error"])) {
        responseJson(false, $resultado["message"], null, 500);
    }

    responseJson(true, "Estado actualizado correctamente", $resultado);
}

public function listarPorRestaurante()
{
    if (!isset($_GET["id_restaurante"])) {
        responseJson(false, "El id_restaurante es obligatorio", null, 400);
    }

    $id_restaurante = intval($_GET["id_restaurante"]);

    $model = new Pedido();
    $pedidos = $model->listarPorRestaurante($id_restaurante);

    responseJson(true, "Pedidos del restaurante encontrados", $pedidos);
}

public function cambiarEstadoRestaurante()
{
    $data = json_decode(file_get_contents("php://input"), true);

    if (!$data) {
        responseJson(false, "No se recibieron datos válidos", null, 400);
    }

    if (
        !isset($data["id_pedido"]) ||
        !isset($data["id_restaurante"]) ||
        !isset($data["id_estado_pedido"])
    ) {
        responseJson(false, "Faltan datos obligatorios", null, 400);
    }

    $id_pedido = intval($data["id_pedido"]);
    $id_restaurante = intval($data["id_restaurante"]);
    $id_estado_pedido = intval($data["id_estado_pedido"]);

    $model = new Pedido();

    $resultado = $model->cambiarEstadoRestaurante(
        $id_pedido,
        $id_restaurante,
        $id_estado_pedido
    );

    if (isset($resultado["error"])) {
        responseJson(false, $resultado["message"], null, 500);
    }

    responseJson(true, "Estado actualizado correctamente", $resultado);
}
public function listarAdmin()
{
    $model = new Pedido();
    $pedidos = $model->listarAdmin();
    responseJson(true, "Pedidos encontrados", $pedidos);
}

public function cambiarEstadoAdmin()
{
    $data = json_decode(file_get_contents("php://input"), true);
    if (!$data || !isset($data["id_pedido"]) || !isset($data["id_estado_pedido"])) {
        responseJson(false, "Faltan datos obligatorios", null, 400);
    }
    $model = new Pedido();
    $resultado = $model->cambiarEstadoAdmin(intval($data["id_pedido"]), intval($data["id_estado_pedido"]));
    if (isset($resultado["error"])) { responseJson(false, $resultado["message"], null, 500); }
    responseJson(true, "Estado actualizado correctamente", $resultado);
}

}
