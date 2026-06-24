import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pedido_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/pedido_service.dart';
import '../cliente/detalle_pedido_screen.dart';

class PedidosRestauranteScreen extends StatefulWidget {
  const PedidosRestauranteScreen({super.key});

  @override
  State<PedidosRestauranteScreen> createState() =>
      _PedidosRestauranteScreenState();
}

class _PedidosRestauranteScreenState extends State<PedidosRestauranteScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final PedidoService _pedidoService = PedidoService();

  late Future<List<Pedido>> _pedidosFuture;
  bool _cargado = false;
  bool _actualizando = false;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = Future.value([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_cargado) {
      _pedidosFuture = _obtenerPedidos();
      _cargado = true;
    }
  }

  Future<List<Pedido>> _obtenerPedidos() async {
    final authProvider = context.read<AuthProvider>();
    final idRestaurante = authProvider.idRestaurante;

    if (idRestaurante == null) {
      throw Exception("No se encontró el restaurante logueado");
    }

    return _pedidoService.listarPorRestaurante(idRestaurante.toString());
  }

  Future<void> _recargar() async {
    setState(() {
      _pedidosFuture = _obtenerPedidos();
    });
  }

  Future<void> _cambiarEstado(
    Pedido pedido,
    int idEstadoPedido,
    String nombreEstado,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final idRestaurante = authProvider.idRestaurante;

    if (idRestaurante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se encontró el restaurante logueado"),
        ),
      );
      return;
    }

    setState(() {
      _actualizando = true;
    });

    try {
      await _pedidoService.cambiarEstadoRestaurante(
        idPedido: int.tryParse(pedido.idPedido) ?? 0,
        idRestaurante: idRestaurante,
        idEstadoPedido: idEstadoPedido,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pedido #${pedido.idPedido} cambiado a $nombreEstado",
          ),
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
              Icons.receipt_long_outlined,
              color: colorPrincipal,
              size: 90,
            ),
            const SizedBox(height: 16),
            Text(
              "No hay pedidos",
              style: TextStyle(
                color: colorTexto,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cuando los clientes realicen pedidos, aparecerán aquí.",
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
                      pedido.clienteCompleto,
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
            Icons.phone_outlined,
            "Teléfono",
            pedido.clienteTelefono.isEmpty
                ? "No disponible"
                : pedido.clienteTelefono,
          ),
          const SizedBox(height: 8),
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
          if (pedido.observacion.isNotEmpty) ...[
            const SizedBox(height: 8),
            _filaInfo(
              Icons.notes_outlined,
              "Observación",
              pedido.observacion,
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
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetallePedidoScreen(
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
          const SizedBox(height: 10),
          _botonesEstado(pedido),
        ],
      ),
    );
  }

  Widget _botonesEstado(Pedido pedido) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _botonEstado(
          texto: "Aceptar",
          idEstado: 2,
          pedido: pedido,
          color: Colors.blue,
        ),
        _botonEstado(
          texto: "Preparando",
          idEstado: 3,
          pedido: pedido,
          color: Colors.deepPurple,
        ),
        _botonEstado(
          texto: "Listo",
          idEstado: 4,
          pedido: pedido,
          color: Colors.green,
        ),
        _botonEstado(
          texto: "Cancelar",
          idEstado: 7,
          pedido: pedido,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _botonEstado({
    required String texto,
    required int idEstado,
    required Pedido pedido,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: _actualizando
          ? null
          : () {
              _cambiarEstado(pedido, idEstado, texto.toLowerCase());
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _estadoPedido(String estado) {
    Color colorEstado = Colors.orange;

    final estadoLower = estado.toLowerCase();

    if (estadoLower.contains("acept")) {
      colorEstado = Colors.blue;
    } else if (estadoLower.contains("prepar")) {
      colorEstado = Colors.deepPurple;
    } else if (estadoLower.contains("list")) {
      colorEstado = Colors.green;
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