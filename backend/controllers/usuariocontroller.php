<?php
require_once __DIR__ . "/../models/usuario.php";
require_once __DIR__ . "/../helpers/response.php";

class UsuarioController
{
    public function listar()
    {
        $rol = $_GET["rol"] ?? null;
        $model = new Usuario();
        responseJson(true, "Usuarios encontrados", $model->listar($rol));
    }

    public function cambiarEstado()
    {
        $data = json_decode(file_get_contents("php://input"), true);
        if (!$data || !isset($data["id_usuario"]) || !isset($data["estado"])) {
            responseJson(false, "Faltan datos obligatorios", null, 400);
        }
        $model = new Usuario();
        responseJson($model->cambiarEstado(intval($data["id_usuario"]), intval($data["estado"])), "Estado actualizado correctamente");
    }

    public function crearRepartidor()
{
    $data = json_decode(
        file_get_contents("php://input"),
        true
    );

    $model = new Usuario();

    $ok = $model->crearRepartidor($data);

    responseJson(
        $ok,
        $ok
            ? "Repartidor creado correctamente"
            : "No se pudo crear el repartidor"
    );
}
}
