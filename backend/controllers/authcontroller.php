<?php

require_once __DIR__ . "/../models/usuario.php";
require_once __DIR__ . "/../helpers/response.php";

class AuthController
{
    public function login()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (!isset($data["correo"]) || !isset($data["password"])) {
            responseJson(false, "Correo y contraseña son obligatorios", null, 400);
        }

        $correo = trim($data["correo"]);
        $password = trim($data["password"]);

        $usuarioModel = new Usuario();
        $usuario = $usuarioModel->login($correo, $password);

        if ($usuario === "inactivo") {
            responseJson(false, "Usuario inactivo", null, 403);
        }

        if (!$usuario) {
            responseJson(false, "Credenciales incorrectas", null, 401);
        }

        responseJson(true, "Login correcto", $usuario);
    }

    public function registrar()
    {
        $data = json_decode(file_get_contents("php://input"), true);

        if (
            !isset($data["nombre"]) ||
            !isset($data["apellido"]) ||
            !isset($data["correo"]) ||
            !isset($data["telefono"]) ||
            !isset($data["password"])
        ) {
            responseJson(false, "Todos los campos son obligatorios", null, 400);
        }

        $nombre = trim($data["nombre"]);
        $apellido = trim($data["apellido"]);
        $correo = trim($data["correo"]);
        $telefono = trim($data["telefono"]);
        $password = trim($data["password"]);

        $usuarioModel = new Usuario();

        $usuario = $usuarioModel->registrarCliente(
            $nombre,
            $apellido,
            $correo,
            $telefono,
            $password
        );

        if (!$usuario) {
            responseJson(false, "No se pudo registrar el cliente", null, 500);
        }

        responseJson(true, "Cliente registrado correctamente", $usuario, 201);
    }
}