import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  Future<List<Usuario>> listarUsuarios({String? rol}) async {
    final extra = rol == null ? '' : '&rol=$rol';
    final url = Uri.parse("${ApiConfig.baseUrl}/usuarios.php?accion=listar$extra");
    final response = await http.get(url).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception("Error al conectar con el servidor");
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data["status"] != true) throw Exception(data["message"] ?? "No se pudieron cargar usuarios");
    final List lista = data["data"] ?? [];
    return lista.map((item) => Usuario.fromJson(item)).toList();
  }

  Future<void> cambiarEstado(int idUsuario, int estado) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/usuarios.php?accion=cambiar_estado");
    final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({"id_usuario": idUsuario, "estado": estado})).timeout(const Duration(seconds: 20));
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200 || data["status"] != true) throw Exception(data["message"] ?? "No se pudo cambiar el estado");
  }

  Future<void> crearRepartidor(
  Map<String, dynamic> body,
) async {

  final url = Uri.parse(
    "${ApiConfig.baseUrl}/usuarios.php?accion=crear_repartidor",
  );

  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(body),
  );

  final Map<String, dynamic> data =
      jsonDecode(response.body);

  if (response.statusCode != 200 ||
      data["status"] != true) {
    throw Exception(
      data["message"] ??
          "No se pudo crear el repartidor",
    );
  }
}
}
