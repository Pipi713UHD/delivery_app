<?php

require_once __DIR__ . "/../config/conexion.php";

class Direccion
{
    private $conexion;

    public function __construct()
    {
        $db = new Conexion();
        $this->conexion = $db->conectar();
    }

    public function listarPorCliente($id_cliente)
    {
        $sql = "SELECT id_direccion, id_cliente, titulo, direccion, referencia, latitud, longitud, principal, estado
                FROM direcciones
                WHERE id_cliente = ? AND estado = 1
                ORDER BY principal DESC, id_direccion DESC";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("i", $id_cliente);
        $stmt->execute();

        $resultado = $stmt->get_result();

        $direcciones = [];
        while ($fila = $resultado->fetch_assoc()) {
            $direcciones[] = $fila;
        }

        return $direcciones;
    }

    public function obtenerPorId($id_direccion)
    {
        $sql = "SELECT id_direccion, id_cliente, titulo, direccion, referencia, latitud, longitud, principal, estado
                FROM direcciones
                WHERE id_direccion = ?
                LIMIT 1";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("i", $id_direccion);
        $stmt->execute();

        $resultado = $stmt->get_result();

        return $resultado->fetch_assoc();
    }

    public function crear($data)
    {
        $id_cliente = intval($data["id_cliente"]);
        $titulo = $data["titulo"] ?? "";
        $direccion = $data["direccion"] ?? "";
        $referencia = $data["referencia"] ?? "";
        $latitud = isset($data["latitud"]) && $data["latitud"] !== "" ? floatval($data["latitud"]) : null;
        $longitud = isset($data["longitud"]) && $data["longitud"] !== "" ? floatval($data["longitud"]) : null;
        $marcarPrincipal = isset($data["principal"]) ? intval($data["principal"]) : 0;

        $this->conexion->begin_transaction();

        try {
            // Si es la primera dirección del cliente, se marca como principal automáticamente
            $sqlConteo = "SELECT COUNT(*) AS total FROM direcciones WHERE id_cliente = ? AND estado = 1";
            $stmtConteo = $this->conexion->prepare($sqlConteo);
            $stmtConteo->bind_param("i", $id_cliente);
            $stmtConteo->execute();
            $totalExistentes = $stmtConteo->get_result()->fetch_assoc()["total"];

            $principal = ($marcarPrincipal === 1 || intval($totalExistentes) === 0) ? 1 : 0;

            if ($principal === 1) {
                $this->quitarPrincipalDeOtras($id_cliente, null);
            }

            $sql = "INSERT INTO direcciones (id_cliente, titulo, direccion, referencia, latitud, longitud, principal, estado)
                    VALUES (?, ?, ?, ?, ?, ?, ?, 1)";

            $stmt = $this->conexion->prepare($sql);
            $stmt->bind_param(
                "isssddi",
                $id_cliente,
                $titulo,
                $direccion,
                $referencia,
                $latitud,
                $longitud,
                $principal
            );
            $stmt->execute();

            $id_direccion = $this->conexion->insert_id;

            $this->conexion->commit();

            return $id_direccion;
        } catch (Exception $e) {
            $this->conexion->rollback();
            return false;
        }
    }

    public function editar($data)
    {
        $id_direccion = intval($data["id_direccion"]);
        $titulo = $data["titulo"] ?? "";
        $direccion = $data["direccion"] ?? "";
        $referencia = $data["referencia"] ?? "";
        $latitud = isset($data["latitud"]) && $data["latitud"] !== "" ? floatval($data["latitud"]) : null;
        $longitud = isset($data["longitud"]) && $data["longitud"] !== "" ? floatval($data["longitud"]) : null;

        $sql = "UPDATE direcciones
                SET titulo = ?, direccion = ?, referencia = ?, latitud = ?, longitud = ?
                WHERE id_direccion = ?";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param(
            "sssddi",
            $titulo,
            $direccion,
            $referencia,
            $latitud,
            $longitud,
            $id_direccion
        );

        return $stmt->execute();
    }

    public function marcarPrincipal($id_direccion, $id_cliente)
    {
        $this->conexion->begin_transaction();

        try {
            $this->quitarPrincipalDeOtras($id_cliente, $id_direccion);

            $sql = "UPDATE direcciones SET principal = 1 WHERE id_direccion = ? AND id_cliente = ?";
            $stmt = $this->conexion->prepare($sql);
            $stmt->bind_param("ii", $id_direccion, $id_cliente);
            $stmt->execute();

            $this->conexion->commit();

            return true;
        } catch (Exception $e) {
            $this->conexion->rollback();
            return false;
        }
    }

    private function quitarPrincipalDeOtras($id_cliente, $id_direccion_excluir)
    {
        if ($id_direccion_excluir) {
            $sql = "UPDATE direcciones SET principal = 0 WHERE id_cliente = ? AND id_direccion != ?";
            $stmt = $this->conexion->prepare($sql);
            $stmt->bind_param("ii", $id_cliente, $id_direccion_excluir);
        } else {
            $sql = "UPDATE direcciones SET principal = 0 WHERE id_cliente = ?";
            $stmt = $this->conexion->prepare($sql);
            $stmt->bind_param("i", $id_cliente);
        }

        $stmt->execute();
    }

    public function eliminar($id_direccion)
    {
        $sql = "UPDATE direcciones SET estado = 0, principal = 0 WHERE id_direccion = ?";
        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("i", $id_direccion);
        return $stmt->execute();
    }
}
