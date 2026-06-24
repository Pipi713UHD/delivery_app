import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pedido_model.dart';
import '../models/carrito_model.dart';

class PedidoService {
  Future<List<Pedido>> listarPorCliente(String idCliente) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=listar_por_cliente&id_cliente=$idCliente",
    );

    final response = await http.get(url).timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudieron cargar los pedidos");
    }

    final List lista = data["data"] ?? [];

    return lista.map((json) => Pedido.fromJson(json)).toList();
  }

  Future<PedidoDetalle> obtenerDetalle(String idPedido) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=detalle&id_pedido=$idPedido",
    );

    final response = await http.get(url).timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudo cargar el detalle");
    }

    return PedidoDetalle.fromJson(data["data"]);
  }

  Future<Map<String, dynamic>> crearPedidoDesdeCarrito({
    required int idCliente,
    required int idRestaurante,
    required int idDireccion,
    required String metodoPago,
    required String observacion,
    required List<CarritoItem> items,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=crear",
    );

    final productos = items.map((item) {
      return {
        "id_producto": int.tryParse(item.producto.idProducto.toString()) ?? 0,
        "cantidad": item.cantidad,
        "observacion": "",
        "extras": [],
      };
    }).toList();

    final body = {
      "id_cliente": idCliente,
      "id_restaurante": idRestaurante,
      "id_direccion": idDireccion,
      "metodo_pago": metodoPago,
      "observacion": observacion,
      "productos": productos,
    };

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data["message"] ?? "Error al crear el pedido");
    }

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudo crear el pedido");
    }

    return data;
  }

  Future<List<Pedido>> listarDisponiblesRepartidor() async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=listar_disponibles_repartidor",
    );

    final response = await http.get(url).timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(
        data["message"] ?? "No se pudieron cargar los pedidos disponibles",
      );
    }

    final List lista = data["data"] ?? [];

    return lista.map((json) => Pedido.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> aceptarPedidoRepartidor({
    required int idPedido,
    required int idRepartidor,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=aceptar_repartidor",
    );

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "id_pedido": idPedido,
            "id_repartidor": idRepartidor,
          }),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data["message"] ?? "Error al aceptar el pedido");
    }

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudo aceptar el pedido");
    }

    return data;
  }

  Future<List<Pedido>> listarPorRepartidor(String idRepartidor) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=listar_por_repartidor&id_repartidor=$idRepartidor",
    );

    final response = await http.get(url).timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(
        data["message"] ?? "No se pudieron cargar las entregas",
      );
    }

    final List lista = data["data"] ?? [];

    return lista.map((json) => Pedido.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> cambiarEstadoRepartidor({
    required int idPedido,
    required int idRepartidor,
    required int idEstadoPedido,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=cambiar_estado_repartidor",
    );

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "id_pedido": idPedido,
            "id_repartidor": idRepartidor,
            "id_estado_pedido": idEstadoPedido,
          }),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data["message"] ?? "Error al cambiar el estado");
    }

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudo cambiar el estado");
    }

    return data;
  }

  Future<List<Pedido>> listarPorRestaurante(String idRestaurante) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=listar_por_restaurante&id_restaurante=$idRestaurante",
    );

    final response = await http.get(url).timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode != 200) {
      throw Exception("Error al conectar con el servidor");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data["status"] != true) {
      throw Exception(
        data["message"] ?? "No se pudieron cargar los pedidos del restaurante",
      );
    }

    final List lista = data["data"] ?? [];

    return lista.map((json) => Pedido.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> cambiarEstadoRestaurante({
    required int idPedido,
    required int idRestaurante,
    required int idEstadoPedido,
  }) async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=cambiar_estado_restaurante",
    );

    final response = await http
        .post(
          url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "id_pedido": idPedido,
            "id_restaurante": idRestaurante,
            "id_estado_pedido": idEstadoPedido,
          }),
        )
        .timeout(
          const Duration(seconds: 20),
        );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data["message"] ?? "Error al cambiar el estado");
    }

    if (data["status"] != true) {
      throw Exception(data["message"] ?? "No se pudo cambiar el estado");
    }

    return data;
  }
  Future<List<Pedido>> listarTodosAdmin() async {
    final url = Uri.parse(
      "${ApiConfig.baseUrl}/pedidos.php?accion=listar_admin",
    );

    final response = await http.get(url).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception("Error al conectar con el servidor");
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data["status"] != true) throw Exception(data["message"] ?? "No se pudieron cargar los pedidos");
    final List lista = data["data"] ?? [];
    return lista.map((json) => Pedido.fromJson(json)).toList();
  }

  Future<void> cambiarEstadoAdmin({required int idPedido, required int idEstadoPedido}) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/pedidos.php?accion=cambiar_estado_admin");
    final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({"id_pedido": idPedido, "id_estado_pedido": idEstadoPedido})).timeout(const Duration(seconds: 20));
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (response.statusCode != 200 || data["status"] != true) throw Exception(data["message"] ?? "No se pudo actualizar el pedido");
  }

}
