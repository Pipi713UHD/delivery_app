<?php

require_once __DIR__ . "/../models/restaurante.php";
require_once __DIR__ . "/../helpers/response.php";

class RestauranteController
{
    public function listar()
    {
        $model = new Restaurante();
        $restaurantes = $model->listar();

        responseJson(true, "Restaurantes encontrados", $restaurantes);
    }

    public function obtener()
    {
        if (!isset($_GET["id_restaurante"])) {
            responseJson(false, "El id_restaurante es obligatorio", null, 400);
        }

        $id_restaurante = intval($_GET["id_restaurante"]);

        $model = new Restaurante();
        $restaurante = $model->obtenerPorId($id_restaurante);

        if (!$restaurante) {
            responseJson(false, "Restaurante no encontrado", null, 404);
        }

        responseJson(true, "Restaurante encontrado", $restaurante);
    }
    public function listarAdmin()
    {
        $solo_activos = isset($_GET["solo_activos"]) && intval($_GET["solo_activos"]) === 1;
        $model = new Restaurante();
        responseJson(true, "Restaurantes encontrados", $model->listarAdmin($solo_activos));
    }

    public function crear()
    {
        $data = json_decode(file_get_contents("php://input"), true);
        if (!$data || empty($data["nombre"])) { responseJson(false, "El nombre es obligatorio", null, 400); }
        $model = new Restaurante();
        $id = $model->crear($data);
        if (!$id) { responseJson(false, "No se pudo crear el restaurante", null, 500); }
        responseJson(true, "Restaurante creado correctamente", ["id_restaurante" => $id], 201);
    }

    public function editar()
    {
        $data = json_decode(file_get_contents("php://input"), true);
        if (!$data || empty($data["id_restaurante"])) { responseJson(false, "El id_restaurante es obligatorio", null, 400); }
        $model = new Restaurante();
        responseJson($model->editar($data), "Restaurante actualizado correctamente");
    }

    public function cambiarEstado()
    {
        $data = json_decode(file_get_contents("php://input"), true);
        if (!$data || !isset($data["id_restaurante"]) || !isset($data["estado"])) { responseJson(false, "Faltan datos obligatorios", null, 400); }
        $model = new Restaurante();
        responseJson($model->cambiarEstado(intval($data["id_restaurante"]), intval($data["estado"])), "Estado actualizado correctamente");
    }

    public function eliminar()
    {
        $data = json_decode(file_get_contents("php://input"), true);
        if (!$data || empty($data["id_restaurante"])) { responseJson(false, "El id_restaurante es obligatorio", null, 400); }
        $model = new Restaurante();
        responseJson($model->eliminar(intval($data["id_restaurante"])), "Restaurante eliminado correctamente");
    }

}
