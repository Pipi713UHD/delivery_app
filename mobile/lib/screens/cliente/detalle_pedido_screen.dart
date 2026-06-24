import 'package:flutter/material.dart';

import '../../models/pedido_model.dart';
import '../../services/pedido_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetallePedidoScreen extends StatefulWidget {
  final String idPedido;

  const DetallePedidoScreen({
    super.key,
    required this.idPedido,
  });

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final PedidoService _pedidoService = PedidoService();

  late Future<PedidoDetalle> _detalleFuture;

  @override
  void initState() {
    super.initState();
    _detalleFuture = _pedidoService.obtenerDetalle(widget.idPedido);
  }

  Future<void> _recargar() async {
    setState(() {
      _detalleFuture = _pedidoService.obtenerDetalle(widget.idPedido);
    });
  }

  Future<void> abrirMapa(
  double lat,
  double lng,
) async {
  final Uri url = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );

  await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _encabezado(),
            Expanded(
              child: FutureBuilder<PedidoDetalle>(
                future: _detalleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorPrincipal,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Error: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }

                  final pedido = snapshot.data;

                  if (pedido == null) {
                    return const Center(
                      child: Text("No se encontró el pedido"),
                    );
                  }

                  return RefreshIndicator(
                    color: colorPrincipal,
                    onRefresh: _recargar,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _tarjetaEstado(pedido),
                        const SizedBox(height: 16),
                        _seccionProductos(pedido),
                        const SizedBox(height: 16),
                        _seccionEntrega(pedido),
                        const SizedBox(height: 16),
                        _seccionPago(pedido),
                        const SizedBox(height: 16),
                        _seccionTotales(pedido),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      decoration: BoxDecoration(
        color: colorPrincipal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              "Pedido #${widget.idPedido}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.receipt_long_outlined,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _tarjetaEstado(PedidoDetalle pedido) {
    return _contenedor(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xffffd6e6),
            child: Icon(
              Icons.delivery_dining,
              color: colorPrincipal,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.restaurante,
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  pedido.fechaPedido,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _estadoPedido(pedido.estado),
        ],
      ),
    );
  }

  Widget _seccionProductos(PedidoDetalle pedido) {
    return _contenedor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion("Productos"),
          const SizedBox(height: 12),
          ...pedido.detalle.map((producto) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xffffd6e6),
                        child: Icon(
                          Icons.fastfood,
                          color: colorPrincipal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${producto.cantidad} x ${producto.producto}",
                          style: TextStyle(
                            color: colorTexto,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        "L. ${producto.subtotal}",
                        style: TextStyle(
                          color: colorTexto,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _filaSimple(
                    "Precio unitario",
                    "L. ${producto.precioUnitario}",
                  ),
                  if (producto.observacion.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _filaSimple(
                      "Observación",
                      producto.observacion,
                    ),
                  ],
                  if (producto.extras.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(),
                    ...producto.extras.map((extra) {
                      return _filaSimple(
                        "Extra: ${extra.extra}",
                        "L. ${extra.precioExtra}",
                      );
                    }),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _seccionEntrega(PedidoDetalle pedido) {
    return _contenedor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion("Entrega"),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
            abrirMapa(
              pedido.latitud,
              pedido.longitud,
            );
          },
          icon: const Icon(Icons.map),
          label: const Text(
          "Abrir en Google Maps",
  ),
),
          const SizedBox(height: 8),
          _filaIcono(
            Icons.notes_outlined,
            "Referencia",
            pedido.referencia.isEmpty ? "Sin referencia" : pedido.referencia,
          ),
          if (pedido.observacion.isNotEmpty) ...[
            const SizedBox(height: 8),
            _filaIcono(
              Icons.chat_bubble_outline,
              "Observación",
              pedido.observacion,
            ),
          ],
        ],
      ),
    );
  }

  Widget _seccionPago(PedidoDetalle pedido) {
    return _contenedor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion("Pago"),
          const SizedBox(height: 12),
          _filaIcono(
            Icons.payments_outlined,
            "Método de pago",
            pedido.metodoPago.isEmpty ? "No especificado" : pedido.metodoPago,
          ),
        ],
      ),
    );
  }

  Widget _seccionTotales(PedidoDetalle pedido) {
    return _contenedor(
      child: Column(
        children: [
          _filaTotal("Subtotal", "L. ${pedido.subtotal}", false),
          const SizedBox(height: 8),
          _filaTotal("Envío", "L. ${pedido.costoEnvio}", false),
          const SizedBox(height: 8),
          _filaTotal("Descuento", "L. ${pedido.descuento}", false),
          const Divider(height: 24),
          _filaTotal("Total", "L. ${pedido.total}", true),
        ],
      ),
    );
  }

  Widget _estadoPedido(String estado) {
    Color colorEstado = Colors.orange;

    final estadoLower = estado.toLowerCase();

    if (estadoLower.contains("pendiente")) {
      colorEstado = Colors.orange;
    } else if (estadoLower.contains("prepar")) {
      colorEstado = Colors.blue;
    } else if (estadoLower.contains("camino")) {
      colorEstado = Colors.purple;
    } else if (estadoLower.contains("entreg")) {
      colorEstado = Colors.green;
    } else if (estadoLower.contains("cancel")) {
      colorEstado = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorEstado.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: colorEstado,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _contenedor({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: TextStyle(
        color: colorTexto,
        fontSize: 19,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _filaIcono(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icono,
          color: colorPrincipal,
          size: 22,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "$titulo: ",
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: valor,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filaSimple(String titulo, String valor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            color: colorTexto,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _filaTotal(
    String titulo,
    String valor,
    bool destacado,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              color: destacado ? colorTexto : Colors.black54,
              fontSize: destacado ? 21 : 16,
              fontWeight: destacado ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            color: destacado ? colorPrincipal : colorTexto,
            fontSize: destacado ? 21 : 16,
            fontWeight: destacado ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ],
    );
  }
}