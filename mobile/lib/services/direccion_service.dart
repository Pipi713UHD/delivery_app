import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/direccion_model.dart';

class DireccionService {
  Future<List<Direccion>> listarPorCliente(int idCliente) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/direcciones.php?accion=listar_por_cliente&id_cliente=$idCliente",
    );

    final response = await http.get(url).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "Error al obtener direcciones");
    }

    final List lista = data["data"] ?? [];
    return lista.map((item) => Direccion.fromJson(item)).toList();
  }

  Future<int> crear({
    required int idCliente,
    required String titulo,
    required String direccion,
    String referencia = "",
    double? latitud,
    double? longitud,
    bool principal = false,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/direcciones.php?accion=crear");

    final response = await http
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id_cliente": idCliente,
            "titulo": titulo,
            "direccion": direccion,
            "referencia": referencia,
            "latitud": latitud,
            "longitud": longitud,
            "principal": principal ? 1 : 0,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data["message"] ?? "Error al conectar con el servidor");
    }

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudo guardar la dirección");
    }

    return int.tryParse(data["data"]["id_direccion"].toString()) ?? 0;
  }

  Future<void> editar({
    required int idDireccion,
    required String titulo,
    required String direccion,
    String referencia = "",
    double? latitud,
    double? longitud,
  }) async {
    await _post("editar", {
      "id_direccion": idDireccion,
      "titulo": titulo,
      "direccion": direccion,
      "referencia": referencia,
      "latitud": latitud,
      "longitud": longitud,
    });
  }

  Future<void> marcarPrincipal({
    required int idDireccion,
    required int idCliente,
  }) async {
    await _post("marcar_principal", {
      "id_direccion": idDireccion,
      "id_cliente": idCliente,
    });
  }

  Future<void> eliminar(int idDireccion) async {
    await _post("eliminar", {"id_direccion": idDireccion});
  }

  Future<void> _post(String accion, Map<String, dynamic> body) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/direcciones.php?accion=$accion");

    final response = await http
        .post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data["message"] ?? "Error en la solicitud");
    }

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudo realizar la acción");
    }
  }
}
