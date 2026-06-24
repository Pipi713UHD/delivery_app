<?php

require_once __DIR__ . "/../models/producto.php";
require_once __DIR__ . "/../helpers/response.php";

class ProductoController
{
    public function listarPorRestaurante()
    {
        if (!isset($_GET["id_restaurante"])) {
            responseJson(false, "El id_restaurante es obligatorio", null, 400);
        }

        $id_restaurante = intval($_GET["id_restaurante"]);

        $model = new Producto();
        $productos = $model->listarPorRestaurante($id_restaurante);

        responseJson(true, "Productos encontrados", $productos);
    }

    public function obtener()
    {
        if (!isset($_GET["id_producto"])) {
            responseJson(false, "El id_producto es obligatorio", null, 400);
        }

        $id_producto = intval($_GET["id_producto"]);

        $model = new Producto();
        $producto = $model->obtenerPorId($id_producto);

        if (!$producto) {
            responseJson(false, "Producto no encontrado", null, 404);
        }

        $extras = $model->listarExtras($id_producto);
        $producto["extras"] = $extras;

        responseJson(true, "Producto encontrado", $producto);
    }

    public function listarAdmin()
    {
        $model = new Producto();
        $productos = $model->listarAdmin();

        responseJson(true, "Productos encontrados", $productos);
    }

    public function crear()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        $model = new Producto();
        $ok = $model->crear($data);

        responseJson(
            $ok,
            $ok ? "Producto creado correctamente" : "No se pudo crear el producto"
        );
    }

    public function editar()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        $model = new Producto();
        $ok = $model->editar($data);

        responseJson(
            $ok,
            $ok ? "Producto actualizado correctamente" : "No se pudo actualizar el producto"
        );
    }

    public function eliminar()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        $model = new Producto();
        $ok = $model->eliminar($data["id_producto"]);

        responseJson(
            $ok,
            $ok ? "Producto eliminado correctamente" : "No se pudo eliminar el producto"
        );
    }
}