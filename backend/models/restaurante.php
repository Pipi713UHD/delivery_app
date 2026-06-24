<?php

require_once __DIR__ . "/../config/conexion.php";

class Restaurante
{
    private $conexion;

    public function __construct()
    {
        $db = new Conexion();
        $this->conexion = $db->conectar();
    }

    public function listar()
    {
        $sql = "SELECT 
                    r.id_restaurante,
                    r.nombre,
                    r.descripcion,
                    r.telefono,
                    r.correo,
                    r.direccion,
                    r.logo,
                    r.portada,
                    r.hora_apertura,
                    r.hora_cierre,
                    r.costo_envio,
                    r.calificacion,
                    cr.nombre AS categoria
                FROM restaurantes r
                INNER JOIN categorias_restaurante cr 
                    ON r.id_categoria_restaurante = cr.id_categoria_restaurante
                WHERE r.estado = 1
                ORDER BY r.nombre ASC";

        $resultado = $this->conexion->query($sql);

        $restaurantes = [];

        while ($fila = $resultado->fetch_assoc()) {
            $restaurantes[] = $fila;
        }

        return $restaurantes;
    }

    public function obtenerPorId($id_restaurante)
    {
        $sql = "SELECT 
                    r.*,
                    cr.nombre AS categoria
                FROM restaurantes r
                INNER JOIN categorias_restaurante cr 
                    ON r.id_categoria_restaurante = cr.id_categoria_restaurante
                WHERE r.id_restaurante = ?
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("i", $id_restaurante);
        $stmt->execute();

        $resultado = $stmt->get_result();

        return $resultado->fetch_assoc();
    }
    public function listarAdmin($solo_activos = false)
    {
        $where = $solo_activos ? "WHERE r.estado = 1" : "";
        $sql = "SELECT r.id_restaurante, r.nombre, r.descripcion, r.telefono, r.correo, r.direccion, r.logo, r.portada, r.hora_apertura, r.hora_cierre, r.costo_envio, r.calificacion, r.estado, cr.nombre AS categoria FROM restaurantes r LEFT JOIN categorias_restaurante cr ON r.id_categoria_restaurante = cr.id_categoria_restaurante $where ORDER BY r.nombre ASC";
        $resultado = $this->conexion->query($sql);
        $restaurantes = [];
        while ($fila = $resultado->fetch_assoc()) { $restaurantes[] = $fila; }
        return $restaurantes;
    }

    public function crear($data)
    {
        $sql = "INSERT INTO restaurantes (id_categoria_restaurante, nombre, descripcion, telefono, correo, direccion, hora_apertura, hora_cierre, costo_envio, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)";
        $stmt = $this->conexion->prepare($sql);
        $id_categoria = intval($data["id_categoria_restaurante"] ?? 1);
        $nombre = $data["nombre"] ?? "";
        $descripcion = $data["descripcion"] ?? "";
        $telefono = $data["telefono"] ?? "";
        $correo = $data["correo"] ?? "";
        $direccion = $data["direccion"] ?? "";
        $hora_apertura = $data["hora_apertura"] ?? "08:00:00";
        $hora_cierre = $data["hora_cierre"] ?? "22:00:00";
        $costo_envio = floatval($data["costo_envio"] ?? 0);
        $stmt->bind_param("isssssssd", $id_categoria, $nombre, $descripcion, $telefono, $correo, $direccion, $hora_apertura, $hora_cierre, $costo_envio);
        return $stmt->execute() ? $this->conexion->insert_id : false;
    }

    public function editar($data)
    {
        $sql = "UPDATE restaurantes SET id_categoria_restaurante=?, nombre=?, descripcion=?, telefono=?, correo=?, direccion=?, hora_apertura=?, hora_cierre=?, costo_envio=? WHERE id_restaurante=?";
        $stmt = $this->conexion->prepare($sql);
        $id_restaurante = intval($data["id_restaurante"] ?? 0);
        $id_categoria = intval($data["id_categoria_restaurante"] ?? 1);
        $nombre = $data["nombre"] ?? "";
        $descripcion = $data["descripcion"] ?? "";
        $telefono = $data["telefono"] ?? "";
        $correo = $data["correo"] ?? "";
        $direccion = $data["direccion"] ?? "";
        $hora_apertura = $data["hora_apertura"] ?? "08:00:00";
        $hora_cierre = $data["hora_cierre"] ?? "22:00:00";
        $costo_envio = floatval($data["costo_envio"] ?? 0);
        $stmt->bind_param("isssssssdi", $id_categoria, $nombre, $descripcion, $telefono, $correo, $direccion, $hora_apertura, $hora_cierre, $costo_envio, $id_restaurante);
        return $stmt->execute();
    }

    public function cambiarEstado($id_restaurante, $estado)
    {
        $sql = "UPDATE restaurantes SET estado=? WHERE id_restaurante=?";
        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("ii", $estado, $id_restaurante);
        return $stmt->execute();
    }

    public function eliminar($id_restaurante)
    {
        return $this->cambiarEstado($id_restaurante, 0);
    }

}
