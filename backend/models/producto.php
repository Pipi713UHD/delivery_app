<?php

require_once __DIR__ . "/../config/conexion.php";

class Producto
{
    private $conexion;

    public function __construct()
    {
        $db = new Conexion();
        $this->conexion = $db->conectar();
    }

    public function listarPorRestaurante($id_restaurante)
    {
        $sql = "SELECT 
                    p.id_producto,
                    p.id_restaurante,
                    p.id_categoria_producto,
                    p.nombre,
                    p.descripcion,
                    p.precio,
                    p.imagen,
                    p.disponible,
                    cp.nombre AS categoria
                FROM productos p
                INNER JOIN categorias_producto cp 
                    ON p.id_categoria_producto = cp.id_categoria_producto
                WHERE p.id_restaurante = ?
                AND p.estado = 1
                AND p.disponible = 1
                ORDER BY cp.nombre, p.nombre ASC";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("i", $id_restaurante);
        $stmt->execute();

        $resultado = $stmt->get_result();

        $productos = [];

        while ($fila = $resultado->fetch_assoc()) {
            $productos[] = $fila;
        }

        return $productos;
    }

    public function obtenerPorId($id_producto)
    {
        $sql = "SELECT 
                    p.*,
                    cp.nombre AS categoria,
                    r.nombre AS restaurante
                FROM productos p
                INNER JOIN categorias_producto cp 
                    ON p.id_categoria_producto = cp.id_categoria_producto
                INNER JOIN restaurantes r
                    ON p.id_restaurante = r.id_restaurante
                WHERE p.id_producto = ?
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("i", $id_producto);
        $stmt->execute();

        $resultado = $stmt->get_result();

        return $resultado->fetch_assoc();
    }

    public function listarExtras($id_producto)
    {
        $sql = "SELECT 
                    id_extra,
                    id_producto,
                    nombre,
                    precio_extra
                FROM extras_producto
                WHERE id_producto = ?
                AND estado = 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("i", $id_producto);
        $stmt->execute();

        $resultado = $stmt->get_result();

        $extras = [];

        while ($fila = $resultado->fetch_assoc()) {
            $extras[] = $fila;
        }

        return $extras;
    }

    public function listarAdmin()
{
    $sql = "SELECT
                p.id_producto,
                p.id_restaurante,
                r.nombre AS restaurante,
                p.id_categoria_producto,
                cp.nombre AS categoria,
                p.nombre,
                p.descripcion,
                p.precio,
                p.imagen,
                p.disponible,
                p.estado
            FROM productos p
            INNER JOIN restaurantes r
                ON p.id_restaurante = r.id_restaurante
            INNER JOIN categorias_producto cp
                ON p.id_categoria_producto = cp.id_categoria_producto
            ORDER BY p.id_producto DESC";

    $resultado = $this->conexion->query($sql);

    $productos = [];

    while ($fila = $resultado->fetch_assoc()) {
        $productos[] = $fila;
    }

    return $productos;
}

public function crear($data)
{
    $sql = "INSERT INTO productos
            (
                id_restaurante,
                id_categoria_producto,
                nombre,
                descripcion,
                precio,
                imagen,
                disponible,
                estado
            )
            VALUES (?, ?, ?, ?, ?, ?, 1, 1)";

    $stmt = $this->conexion->prepare($sql);

    $id_restaurante = intval($data["id_restaurante"]);
    $id_categoria_producto = intval($data["id_categoria_producto"]);
    $nombre = $data["nombre"];
    $descripcion = $data["descripcion"] ?? "";
    $precio = floatval($data["precio"]);
    $imagen = $data["imagen"] ?? "";

    $stmt->bind_param(
        "iissds",
        $id_restaurante,
        $id_categoria_producto,
        $nombre,
        $descripcion,
        $precio,
        $imagen
    );

    return $stmt->execute();
}

public function editar($data)
{
    $sql = "UPDATE productos
            SET
                id_restaurante = ?,
                id_categoria_producto = ?,
                nombre = ?,
                descripcion = ?,
                precio = ?,
                imagen = ?
            WHERE id_producto = ?";

    $stmt = $this->conexion->prepare($sql);

    $id_producto = intval($data["id_producto"]);
    $id_restaurante = intval($data["id_restaurante"]);
    $id_categoria_producto = intval($data["id_categoria_producto"]);
    $nombre = $data["nombre"];
    $descripcion = $data["descripcion"] ?? "";
    $precio = floatval($data["precio"]);
    $imagen = $data["imagen"] ?? "";

    $stmt->bind_param(
        "iissdsi",
        $id_restaurante,
        $id_categoria_producto,
        $nombre,
        $descripcion,
        $precio,
        $imagen,
        $id_producto
    );

    return $stmt->execute();
}

public function eliminar($id_producto)
{
    $sql = "UPDATE productos
            SET estado = 0
            WHERE id_producto = ?";

    $stmt = $this->conexion->prepare($sql);
    $stmt->bind_param("i", $id_producto);

    return $stmt->execute();
}
}