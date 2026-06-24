<?php

class Conexion
{
    private $host = "127.0.0.1";
    private $usuario = "root";
    private $password = "";
    private $base_datos = "delivery_app";
    private $puerto = 3306;

    public function conectar()
    {
        mysqli_report(MYSQLI_REPORT_OFF);

        $conexion = new mysqli(
            $this->host,
            $this->usuario,
            $this->password,
            $this->base_datos,
            $this->puerto
        );

        if ($conexion->connect_errno) {
            http_response_code(500);
            echo json_encode([
                "status" => false,
                "message" => "Error de conexión a la base de datos",
                "error" => $conexion->connect_error,
                "host" => $this->host,
                "usuario" => $this->usuario,
                "base_datos" => $this->base_datos,
                "puerto" => $this->puerto
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $conexion->set_charset("utf8");

        return $conexion;
    }
}