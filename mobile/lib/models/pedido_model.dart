class Pedido {
  final String idPedido;
  final String idCliente;
  final String idRestaurante;
  final String restaurante;
  final String total;
  final String metodoPago;
  final String observacion;
  final String estado;
  final String fechaPedido;

  final String clienteNombre;
  final String clienteApellido;
  final String clienteTelefono;



  Pedido({
    required this.idPedido,
    required this.idCliente,
    required this.idRestaurante,
    required this.restaurante,
    required this.total,
    required this.metodoPago,
    required this.observacion,
    required this.estado,
    required this.fechaPedido,
    required this.clienteNombre,
    required this.clienteApellido,
    required this.clienteTelefono,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      idPedido: json["id_pedido"]?.toString() ?? "",
      idCliente: json["id_cliente"]?.toString() ?? "",
      idRestaurante: json["id_restaurante"]?.toString() ?? "",
      restaurante: json["restaurante"]?.toString() ??
          json["nombre_restaurante"]?.toString() ??
          "Restaurante",
      total: json["total"]?.toString() ?? "0.00",
      metodoPago: json["metodo_pago"]?.toString() ?? "",
      observacion: json["observacion"]?.toString() ?? "",
      estado: json["estado"]?.toString() ??
          json["estado_pedido"]?.toString() ??
          "Pendiente",
      fechaPedido: json["fecha_pedido"]?.toString() ??
          json["fecha"]?.toString() ??
          "",
      clienteNombre: json["cliente_nombre"]?.toString() ?? "",
      clienteApellido: json["cliente_apellido"]?.toString() ?? "",
      clienteTelefono: json["cliente_telefono"]?.toString() ?? "",
    );
  }

  String get clienteCompleto {
    final nombre = "$clienteNombre $clienteApellido".trim();
    return nombre.isEmpty ? "Cliente" : nombre;
  }
}

class PedidoDetalle {
  final String idPedido;
  final String idCliente;
  final String restaurante;
  final String estado;
  final String direccion;
  final String referencia;
  final double latitud;
  final double longitud;
  final String subtotal;
  final String costoEnvio;
  final String descuento;
  final String total;
  final String metodoPago;
  final String observacion;
  final String fechaPedido;
  final List<ProductoPedidoDetalle> detalle;

  PedidoDetalle({
    required this.idPedido,
    required this.idCliente,
    required this.restaurante,
    required this.estado,
    required this.direccion,
    required this.referencia,
    required this.latitud,
    required this.longitud,
    required this.subtotal,
    required this.costoEnvio,
    required this.descuento,
    required this.total,
    required this.metodoPago,
    required this.observacion,
    required this.fechaPedido,
    required this.detalle,
    
  });

  factory PedidoDetalle.fromJson(Map<String, dynamic> json) {
    final List listaDetalle = json["detalle"] ?? [];

    return PedidoDetalle(
      idPedido: json["id_pedido"]?.toString() ?? "",
      idCliente: json["id_cliente"]?.toString() ?? "",
      restaurante: json["restaurante"]?.toString() ?? "Restaurante",
      estado: json["estado"]?.toString() ?? "Pendiente",
      direccion: json["direccion"]?.toString() ?? "",
      referencia: json["referencia"]?.toString() ?? "",
      latitud:
          double.tryParse(
            json["latitud"].toString(),
          ) ??
          0,

      longitud:
          double.tryParse(
            json["longitud"].toString(),
          ) ??
          0,
      subtotal: json["subtotal"]?.toString() ?? "0.00",
      costoEnvio: json["costo_envio"]?.toString() ?? "0.00",
      descuento: json["descuento"]?.toString() ?? "0.00",
      total: json["total"]?.toString() ?? "0.00",
      metodoPago: json["metodo_pago"]?.toString() ?? "",
      observacion: json["observacion"]?.toString() ?? "",
      fechaPedido: json["fecha_pedido"]?.toString() ?? "",
      detalle: listaDetalle
          .map((item) => ProductoPedidoDetalle.fromJson(item))
          .toList(),
    );
  }
}

class ProductoPedidoDetalle {
  final String idDetallePedido;
  final String idProducto;
  final String producto;
  final String cantidad;
  final String precioUnitario;
  final String subtotal;
  final String observacion;
  final List<ExtraPedidoDetalle> extras;

  ProductoPedidoDetalle({
    required this.idDetallePedido,
    required this.idProducto,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.observacion,
    required this.extras,
  });

  factory ProductoPedidoDetalle.fromJson(Map<String, dynamic> json) {
    final List listaExtras = json["extras"] ?? [];

    return ProductoPedidoDetalle(
      idDetallePedido: json["id_detalle_pedido"]?.toString() ?? "",
      idProducto: json["id_producto"]?.toString() ?? "",
      producto: json["producto"]?.toString() ?? "Producto",
      cantidad: json["cantidad"]?.toString() ?? "0",
      precioUnitario: json["precio_unitario"]?.toString() ?? "0.00",
      subtotal: json["subtotal"]?.toString() ?? "0.00",
      observacion: json["observacion"]?.toString() ?? "",
      extras: listaExtras
          .map((item) => ExtraPedidoDetalle.fromJson(item))
          .toList(),
    );
  }
}

class ExtraPedidoDetalle {
  final String idPedidoExtra;
  final String extra;
  final String precioExtra;

  ExtraPedidoDetalle({
    required this.idPedidoExtra,
    required this.extra,
    required this.precioExtra,
  });

  factory ExtraPedidoDetalle.fromJson(Map<String, dynamic> json) {
    return ExtraPedidoDetalle(
      idPedidoExtra: json["id_pedido_extra"]?.toString() ?? "",
      extra: json["extra"]?.toString() ?? "",
      precioExtra: json["precio_extra"]?.toString() ?? "0.00",
    );
  }
}