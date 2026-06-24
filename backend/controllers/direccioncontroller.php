<?php

require_once __DIR__ . "/../models/direccion.php";
require_once __DIR__ . "/../helpers/response.php";

class DireccionController
{
    public function listarPorCliente()
    {
        if (!isset($_GET["id_cliente"])) {
            responseJson(false, "El id_cliente es obligatorio", null, 400);
        }

        $id_cliente = intval($_GET["id_cliente"]);

        $model = new Direccion();
        $direcciones = $model->listarPorCliente($id_cliente);

        responseJson(true, "Direcciones encontradas", $direcciones);
    }

    public function obtener()
    {
        if (!isset($_GET["id_direccion"])) {
            responseJson(false, "El id_direccion es obligatorio", null, 400);
        }

        $id_direccion = intval($_GET["id_direccion"]);

        $model = new Direccion();
        $direccion = $model->obtenerPorId($id_direccion);

        if (!$direccion) {
            responseJson(false, "Dirección no encontrada", null, 404);
        }

        responseJson(true, "Dirección encontrada", $direccion);
    }

    public function crear()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!$data || empty($data["id_cliente"]) || empty($data["direccion"])) {
            responseJson(false, "El id_cliente y la dirección son obligatorios", null, 400);
        }

        $model = new Direccion();
        $id = $model->crear($data);

        if (!$id) {
            responseJson(false, "No se pudo guardar la dirección", null, 500);
        }

        responseJson(true, "Dirección guardada correctamente", ["id_direccion" => $id], 201);
    }

    public function editar()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!$data || empty($data["id_direccion"]) || empty($data["direccion"])) {
            responseJson(false, "El id_direccion y la dirección son obligatorios", null, 400);
        }

        $model = new Direccion();
        $ok = $model->editar($data);

        responseJson($ok, $ok ? "Dirección actualizada correctamente" : "No se pudo actualizar la dirección");
    }

    public function marcarPrincipal()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!$data || empty($data["id_direccion"]) || empty($data["id_cliente"])) {
            responseJson(false, "El id_direccion y el id_cliente son obligatorios", null, 400);
        }

        $model = new Direccion();
        $ok = $model->marcarPrincipal(intval($data["id_direccion"]), intval($data["id_cliente"]));

        responseJson($ok, $ok ? "Dirección marcada como principal" : "No se pudo actualizar la dirección principal");
    }

    public function eliminar()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!$data || empty($data["id_direccion"])) {
            responseJson(false, "El id_direccion es obligatorio", null, 400);
        }

        $model = new Direccion();
        $ok = $model->eliminar(intval($data["id_direccion"]));

        responseJson($ok, $ok ? "Dirección eliminada correctamente" : "No se pudo eliminar la dirección");
    }
}
