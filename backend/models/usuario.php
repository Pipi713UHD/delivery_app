<?php

require_once __DIR__ . "/../config/conexion.php";

class Usuario
{
    private $conexion;

    public function __construct()
    {
        $db = new Conexion();
        $this->conexion = $db->conectar();
    }

    public function login($correo, $password)
{
    $sql = "SELECT 
                u.id_usuario,
                u.id_rol,
                r.nombre AS rol,
                u.nombre,
                u.apellido,
                u.correo,
                u.telefono,
                u.password,
                u.estado
            FROM usuarios u
            INNER JOIN roles r ON u.id_rol = r.id_rol
            WHERE u.correo = ?
            LIMIT 1";

    $stmt = $this->conexion->prepare($sql);
    $stmt->bind_param("s", $correo);
    $stmt->execute();

    $resultado = $stmt->get_result();

    if ($resultado->num_rows === 0) {
        return null;
    }

    $usuario = $resultado->fetch_assoc();

    if ($password != $usuario["password"]) {
        return null;
    }

    if ($usuario["estado"] != 1) {
        return "inactivo";
    }

    unset($usuario["password"]);

    $usuario["id_cliente"] = null;
    $usuario["id_repartidor"] = null;
    $usuario["id_restaurante"] = null;

    if ($usuario["rol"] == "cliente") {
        $sqlCliente = "SELECT id_cliente 
                       FROM clientes 
                       WHERE id_usuario = ? 
                       LIMIT 1";

        $stmtCliente = $this->conexion->prepare($sqlCliente);
        $stmtCliente->bind_param("i", $usuario["id_usuario"]);
        $stmtCliente->execute();

        $resCliente = $stmtCliente->get_result();
        $cliente = $resCliente->fetch_assoc();

        if ($cliente) {
            $usuario["id_cliente"] = $cliente["id_cliente"];
        }
    }

    if ($usuario["rol"] == "repartidor") {
        $sqlRepartidor = "SELECT id_repartidor 
                          FROM repartidores 
                          WHERE id_usuario = ? 
                          LIMIT 1";

        $stmtRepartidor = $this->conexion->prepare($sqlRepartidor);
        $stmtRepartidor->bind_param("i", $usuario["id_usuario"]);
        $stmtRepartidor->execute();

        $resRepartidor = $stmtRepartidor->get_result();
        $repartidor = $resRepartidor->fetch_assoc();

        if ($repartidor) {
            $usuario["id_repartidor"] = $repartidor["id_repartidor"];
        }
    }

    if ($usuario["rol"] == "restaurante") {
        $sqlRestaurante = "SELECT id_restaurante 
                           FROM restaurante_usuarios 
                           WHERE id_usuario = ?
                           AND estado = 1
                           LIMIT 1";

        $stmtRestaurante = $this->conexion->prepare($sqlRestaurante);
        $stmtRestaurante->bind_param("i", $usuario["id_usuario"]);
        $stmtRestaurante->execute();

        $resRestaurante = $stmtRestaurante->get_result();
        $restaurante = $resRestaurante->fetch_assoc();

        if ($restaurante) {
            $usuario["id_restaurante"] = $restaurante["id_restaurante"];
        }
    }

    return $usuario;
}

    public function registrarCliente($nombre, $apellido, $correo, $telefono, $password)
    {
        $this->conexion->begin_transaction();

        try {
            $id_rol_cliente = 1;

            $sqlUsuario = "INSERT INTO usuarios 
                            (id_rol, nombre, apellido, correo, telefono, password)
                           VALUES (?, ?, ?, ?, ?, ?)";

            $stmt = $this->conexion->prepare($sqlUsuario);
            $stmt->bind_param(
                "isssss",
                $id_rol_cliente,
                $nombre,
                $apellido,
                $correo,
                $telefono,
                $password
            );

            $stmt->execute();

            $id_usuario = $this->conexion->insert_id;

            $sqlCliente = "INSERT INTO clientes (id_usuario) VALUES (?)";
            $stmtCliente = $this->conexion->prepare($sqlCliente);
            $stmtCliente->bind_param("i", $id_usuario);
            $stmtCliente->execute();

            $this->conexion->commit();

            return [
                "id_usuario" => $id_usuario,
                "nombre" => $nombre,
                "apellido" => $apellido,
                "correo" => $correo
            ];
        } catch (Exception $e) {
            $this->conexion->rollback();
            return false;
        }
    }
    public function listar($rol = null)
    {
        $where = "";
        $params = [];
        $types = "";
        if ($rol) { $where = "WHERE LOWER(r.nombre) = ?"; $params[] = strtolower($rol); $types .= "s"; }
        $sql = "SELECT u.id_usuario, u.id_rol, r.nombre AS rol, u.nombre, u.apellido, u.correo, u.telefono, u.estado FROM usuarios u INNER JOIN roles r ON u.id_rol = r.id_rol $where ORDER BY u.nombre ASC";
        $stmt = $this->conexion->prepare($sql);
        if ($rol) { $stmt->bind_param($types, ...$params); }
        $stmt->execute();
        $res = $stmt->get_result();
        $usuarios = [];
        while ($fila = $res->fetch_assoc()) { $usuarios[] = $fila; }
        return $usuarios;
    }

    public function cambiarEstado($id_usuario, $estado)
    {
        $sql = "UPDATE usuarios SET estado=? WHERE id_usuario=?";
        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("ii", $estado, $id_usuario);
        return $stmt->execute();
    }

    public function crearRepartidor($data)
{
    $this->conexion->begin_transaction();

    try {

        $idRol = 3;

        $sqlUsuario = "INSERT INTO usuarios
        (
            id_rol,
            nombre,
            apellido,
            correo,
            telefono,
            password,
            estado
        )
        VALUES
        (
            ?, ?, ?, ?, ?, ?, 1
        )";

        $stmt = $this->conexion->prepare($sqlUsuario);

        $stmt->bind_param(
            "isssss",
            $idRol,
            $data["nombre"],
            $data["apellido"],
            $data["correo"],
            $data["telefono"],
            $data["password"]
        );

        $stmt->execute();

        $idUsuario = $this->conexion->insert_id;

        $sqlRepartidor = "INSERT INTO repartidores
        (
            id_usuario,
            tipo_vehiculo,
            placa,
            licencia,
            disponible,
            calificacion
        )
        VALUES
        (
            ?, ?, ?, ?, 1, 0
        )";

        $stmtRep = $this->conexion->prepare($sqlRepartidor);

        $stmtRep->bind_param(
            "isss",
            $idUsuario,
            $data["tipo_vehiculo"],
            $data["placa"],
            $data["licencia"]
        );

        $stmtRep->execute();

        $this->conexion->commit();

        return true;

    } catch (Exception $e) {

        $this->conexion->rollback();

        return false;
    }
}

}
