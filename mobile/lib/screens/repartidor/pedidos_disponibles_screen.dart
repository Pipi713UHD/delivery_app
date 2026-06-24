import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pedido_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/pedido_service.dart';
import 'detalle_pedido_screen.dart';

class PedidosDisponiblesScreen extends StatefulWidget {
  const PedidosDisponiblesScreen({super.key});

  @override
  State<PedidosDisponiblesScreen> createState() =>
      _PedidosDisponiblesScreenState();
}

class _PedidosDisponiblesScreenState extends State<PedidosDisponiblesScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final PedidoService _pedidoService = PedidoService();

  late Future<List<Pedido>> _pedidosFuture;
  bool _aceptando = false;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _pedidoService.listarDisponiblesRepartidor();
  }

  Future<void> _recargar() async {
    setState(() {
      _pedidosFuture = _pedidoService.listarDisponiblesRepartidor();
    });
  }

  Future<void> _aceptarPedido(Pedido pedido) async {
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
      _aceptando = true;
    });

    try {
      await _pedidoService.aceptarPedidoRepartidor(
        idPedido: int.tryParse(pedido.idPedido) ?? 0,
        idRepartidor: idRepartidor,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pedido #${pedido.idPedido} aceptado"),
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
          _aceptando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Pedido>>(
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
              Icons.inbox_outlined,
              color: colorPrincipal,
              size: 90,
            ),
            const SizedBox(height: 16),
            Text(
              "No hay pedidos disponibles",
              style: TextStyle(
                color: colorTexto,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cuando existan pedidos sin repartidor, aparecerán aquí.",
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xffffd6e6),
                radius: 28,
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: colorPrincipal,
                  size: 30,
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
              Expanded(
                child: ElevatedButton(
                  onPressed: _aceptando
                      ? null
                      : () {
                          _aceptarPedido(pedido);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrincipal,
                  ),
                  child: const Text(
                    "Aceptar",
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: const TextStyle(
          color: Colors.orange,
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