import 'package:flutter/material.dart';

import '../cliente/detalle_pedido_screen.dart' as cliente;

class DetallePedidoRepartidorScreen extends StatelessWidget {
  final String idPedido;

  const DetallePedidoRepartidorScreen({
    super.key,
    required this.idPedido,
  });

  @override
  Widget build(BuildContext context) {
    return cliente.DetallePedidoScreen(
      idPedido: idPedido,
    );
  }
}