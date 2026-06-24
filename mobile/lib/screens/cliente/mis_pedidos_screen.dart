import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pedido_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/pedido_service.dart';
import 'detalle_pedido_screen.dart';

class MisPedidosScreen extends StatefulWidget {
  const MisPedidosScreen({super.key});

  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final PedidoService _pedidoService = PedidoService();

  late Future<List<Pedido>> _pedidosFuture;
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = Future.value([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_cargado) {
      _pedidosFuture = _obtenerPedidosUsuario();
      _cargado = true;
    }
  }

  Future<List<Pedido>> _obtenerPedidosUsuario() async {
    final authProvider = context.read<AuthProvider>();
    final idCliente = authProvider.idCliente;

    if (idCliente == null) {
      throw Exception("No se encontró el cliente logueado");
    }

    return _pedidoService.listarPorCliente(idCliente.toString());
  }

  Future<void> _recargar() async {
    setState(() {
      _pedidosFuture = _obtenerPedidosUsuario();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _encabezado(usuario?.nombreCompleto ?? "Cliente"),
            Expanded(
              child: FutureBuilder<List<Pedido>>(
                future: _pedidosFuture,
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

                  final pedidos = snapshot.data ?? [];

                  if (pedidos.isEmpty) {
                    return _sinPedidos();
                  }

                  return RefreshIndicator(
                    color: colorPrincipal,
                    onRefresh: _recargar,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidos[index];
                        return _pedidoCard(pedido);
                      },
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

  Widget _encabezado(String nombreCliente) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mis pedidos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  nombreCliente,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
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

  Widget _sinPedidos() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: colorPrincipal,
              size: 95,
            ),
            const SizedBox(height: 18),
            Text(
              "No tienes pedidos",
              style: TextStyle(
                color: colorTexto,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cuando confirmes un pedido, aparecerá en esta sección.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pedidoCard(Pedido pedido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallePedidoScreen(
                idPedido: pedido.idPedido,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xffffd6e6),
                  radius: 28,
                  child: Icon(
                    Icons.delivery_dining,
                    color: colorPrincipal,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pedido #${pedido.idPedido}",
                        style: TextStyle(
                          color: colorTexto,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pedido.restaurante,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _estadoPedido(pedido.estado),
              ],
            ),
            const SizedBox(height: 16),
            _filaInfo(
              icono: Icons.payments_outlined,
              titulo: "Método de pago",
              valor: pedido.metodoPago.isEmpty
                  ? "No especificado"
                  : pedido.metodoPago,
            ),
            const SizedBox(height: 8),
            _filaInfo(
              icono: Icons.calendar_today_outlined,
              titulo: "Fecha",
              valor: pedido.fechaPedido.isEmpty ? "Sin fecha" : pedido.fechaPedido,
            ),
            if (pedido.observacion.isNotEmpty) ...[
              const SizedBox(height: 8),
              _filaInfo(
                icono: Icons.notes_outlined,
                titulo: "Observación",
                valor: pedido.observacion,
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Total",
                    style: TextStyle(
                      color: colorTexto,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  "L. ${pedido.total}",
                  style: TextStyle(
                    color: colorPrincipal,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoPedido(String estado) {
    Color colorEstado = Colors.orange;
    String textoEstado = estado;

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
        textoEstado,
        style: TextStyle(
          color: colorEstado,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _filaInfo({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icono,
          color: colorPrincipal,
          size: 21,
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
}