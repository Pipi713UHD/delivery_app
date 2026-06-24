import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/producto_model.dart';

class ProductoService {
  Future<List<Producto>> listarPorRestaurante(String idRestaurante) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/productos.php?accion=listar_por_restaurante&id_restaurante=$idRestaurante",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "Error al obtener productos");
    }

    final List lista = data["data"];

    return lista.map((item) => Producto.fromJson(item)).toList();
  }

  Future<List<Producto>> listarAdmin() async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/productos.php?accion=listar_admin",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"]);
    }

    final List lista = data["data"];

    return lista.map((item) => Producto.fromJson(item)).toList();
  }

  Future<void> crearProducto(Map<String, dynamic> body) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/productos.php?accion=crear",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"]);
    }
  }

  Future<void> editarProducto(Map<String, dynamic> body) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/productos.php?accion=editar",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"]);
    }
  }

  Future<void> eliminarProducto(String idProducto) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/productos.php?accion=eliminar",
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "id_producto": idProducto,
      }),
    );

    final data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"]);
    }
  }
}