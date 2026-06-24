import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/usuario_model.dart';

class AuthService {
  Future<Usuario> login({
    required String correo,
    required String password,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/auth.php?accion=login",
    );

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "correo": correo,
            "password": password,
          }),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "Correo o contraseña incorrectos");
    }

    return Usuario.fromJson(data["data"]);
  }

  Future<void> registrar({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/auth.php?accion=registrar",
    );

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "nombre": nombre,
            "apellido": apellido,
            "correo": correo,
            "telefono": telefono,
            "password": password,
          }),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data["message"] ?? "Error al conectar con el servidor");
    }

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudo registrar el usuario");
    }
  }
}