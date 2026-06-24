import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/restaurante_model.dart';

class RestauranteService {
  Future<List<Restaurante>> listarRestaurantes({bool soloActivos = true}) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/restaurantes.php?accion=listar_admin&solo_activos=${soloActivos ? 1 : 0}",
    );
    final response = await http.get(url).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception("Error al conectar con el servidor");
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data["status"] != true) throw Exception(data["message"] ?? "Error al obtener restaurantes");
    final List lista = data["data"] ?? [];
    return lista.map((item) => Restaurante.fromJson(item)).toList();
  }

  Future<void> crearRestaurante(Map<String, dynamic> body) async {
    await _post("crear", body);
  }

  Future<void> editarRestaurante(Map<String, dynamic> body) async {
    await _post("editar", body);
  }

  Future<void> eliminarRestaurante(String idRestaurante) async {
    await _post("eliminar", {"id_restaurante": idRestaurante});
  }

  Future<void> cambiarEstado(String idRestaurante, int estado) async {
    await _post("cambiar_estado", {"id_restaurante": idRestaurante, "estado": estado});
  }

  Future<void> _post(String accion, Map<String, dynamic> body) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/restaurantes.php?accion=$accion");
    final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(body)).timeout(const Duration(seconds: 20));
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) throw Exception(data["message"] ?? "Error en la solicitud");
    if (data["status"] != true) throw Exception(data["message"] ?? "No se pudo realizar la acción");
  }
}
