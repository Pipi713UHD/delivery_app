import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pedido_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/pedido_service.dart';
import 'detalle_pedido_screen.dart';

class EntregasScreen extends StatefulWidget {
  const EntregasScreen({super.key});

  @override
  State<EntregasScreen> createState() => _EntregasScreenState();
}

class _EntregasScreenState extends State<EntregasScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final PedidoService _pedidoService = PedidoService();

  late Future<List<Pedido>> _entregasFuture;
  bool _cargado = false;
  bool _actualizando = false;

  @override
  void initState() {
    super.initState();
    _entregasFuture = Future.value([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_cargado) {
      _entregasFuture = _obtenerEntregas();
      _cargado = true;
    }
  }

  Future<List<Pedido>> _obtenerEntregas() async {
    final authProvider = context.read<AuthProvider>();
    final idRepartidor = authProvider.idRepartidor;

    if (idRepartidor == null) {
      throw Exception("No se encontró el repartidor logueado");
    }

    return _pedidoService.listarPorRepartidor(idRepartidor.toString());
  }

  Future<void> _recargar() async {
    setState(() {
      _entregasFuture = _obtenerEntregas();
    });
  }

  Future<void> _marcarEntregado(Pedido pedido) async {
    final authProvider = context.read<AuthProvider>();
    final idRepartidor = authProvider.idRepartidor;

    if (idRepartidor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se encontró el repartidor logueado"),
        ),
      );
      return;
    }

    setState(() {
      _actualizando = true;
    });

    try {
      await _pedidoService.cambiarEstadoRepartidor(
        idPedido: int.tryParse(pedido.idPedido) ?? 0,
        idRepartidor: idRepartidor,
        idEstadoPedido: 6,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pedido #${pedido.idPedido} marcado como entregado"),
        ),
      );

      await _recargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _actualizando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pedido>>(
      future: _entregasFuture,
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
          return _sinEntregas();
        }

        return RefreshIndicator(
          color: colorPrincipal,
          onRefresh: _recargar,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return _entregaCard(pedido);
            },
          ),
        );
      },
    );
  }

  Widget _sinEntregas() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delivery_dining,
              color: colorPrincipal,
              size: 90,
            ),
            const SizedBox(height: 16),
            Text(
              "No tienes entregas",
              style: TextStyle(
                color: colorTexto,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cuando aceptes un pedido, aparecerá en esta sección.",
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

  Widget _entregaCard(Pedido pedido) {
    final estadoLower = pedido.estado.toLowerCase();
    final entregado = estadoLower.contains("entreg");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(22),
      ),
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
          const SizedBox(height: 14),
          _filaInfo(
            Icons.payments_outlined,
            "Pago",
            pedido.metodoPago.isEmpty ? "No especificado" : pedido.metodoPago,
          ),
          const SizedBox(height: 8),
          _filaInfo(
            Icons.calendar_today_outlined,
            "Fecha",
            pedido.fechaPedido,
          ),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallePedidoRepartidorScreen(
                          idPedido: pedido.idPedido,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Ver detalle",
                    style: TextStyle(
                      color: colorPrincipal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (!entregado)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _actualizando
                        ? null
                        : () {
                            _marcarEntregado(pedido);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrincipal,
                    ),
                    child: const Text(
                      "Entregado",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _estadoPedido(String estado) {
    Color colorEstado = Colors.orange;

    final estadoLower = estado.toLowerCase();

    if (estadoLower.contains("camino")) {
      colorEstado = Colors.purple;
    } else if (estadoLower.contains("entreg")) {
      colorEstado = Colors.green;
    } else if (estadoLower.contains("pendiente")) {
      colorEstado = Colors.orange;
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

  Widget _filaInfo(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Row(
      children: [
        Icon(
          icono,
          color: colorPrincipal,
          size: 21,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$titulo: $valor",
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}