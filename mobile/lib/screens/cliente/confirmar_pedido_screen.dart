import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../services/pedido_service.dart';
import '../../models/direccion_model.dart';
import '../../services/direccion_service.dart';
import 'direcciones_screen.dart';

class ConfirmarPedidoScreen extends StatefulWidget {
  const ConfirmarPedidoScreen({super.key});

  @override
  State<ConfirmarPedidoScreen> createState() => _ConfirmarPedidoScreenState();
}

class _ConfirmarPedidoScreenState extends State<ConfirmarPedidoScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final TextEditingController _observacionController = TextEditingController();

  final PedidoService _pedidoService = PedidoService();
  final DireccionService _direccionService = DireccionService();

  String _metodoPago = "efectivo";
  bool _cargando = false;

  late Future<List<Direccion>> _direccionesFuture;
  Direccion? _direccionSeleccionada;

  final double costoEnvio = 40.00;

  @override
  void initState() {
    super.initState();
    _cargarDirecciones();
  }

  void _cargarDirecciones() {
    final idCliente = context.read<AuthProvider>().idCliente;

    if (idCliente == null) {
      _direccionesFuture = Future.value([]);
      return;
    }

    _direccionesFuture = _direccionService.listarPorCliente(idCliente).then((lista) {
      if (lista.isNotEmpty) {
        final principal = lista.firstWhere(
          (direccion) => direccion.principal,
          orElse: () => lista.first,
        );

        if (mounted) {
          setState(() {
            _direccionSeleccionada = principal;
          });
        } else {
          _direccionSeleccionada = principal;
        }
      }
      return lista;
    });
  }

  Future<void> _recargarDirecciones() async {
    setState(() {
      _direccionSeleccionada = null;
      _cargarDirecciones();
    });
  }

  Future<void> _irAAgregarDireccion() async {
    final idCliente = context.read<AuthProvider>().idCliente;

    if (idCliente == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DireccionesScreen(),
      ),
    );

    if (!mounted) return;
    _recargarDirecciones();
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _confirmarPedido() async {
    final carritoProvider = context.read<CarritoProvider>();
    final authProvider = context.read<AuthProvider>();

    if (carritoProvider.estaVacio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El carrito está vacío"),
        ),
      );
      return;
    }

    final idCliente = authProvider.idCliente;

    if (idCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se encontró el cliente logueado"),
        ),
      );
      return;
    }

    if (_direccionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona una dirección de entrega"),
        ),
      );
      return;
    }

    final idRestaurante = int.tryParse(
          carritoProvider.items.first.producto.idRestaurante.toString(),
        ) ??
        1;

    setState(() {
      _cargando = true;
    });

    try {
      await _pedidoService.crearPedidoDesdeCarrito(
        idCliente: idCliente,
        idRestaurante: idRestaurante,
        idDireccion: _direccionSeleccionada!.idDireccion,
        metodoPago: _metodoPago,
        observacion: _observacionController.text.trim(),
        items: carritoProvider.items,
      );

      carritoProvider.vaciarCarrito();

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Pedido confirmado"),
            content: const Text(
              "Tu pedido fue registrado correctamente.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Aceptar",
                  style: TextStyle(
                    color: colorPrincipal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.popUntil(context, (route) => route.isFirst);
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
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarritoProvider>(
      builder: (context, carritoProvider, child) {
        final subtotal = carritoProvider.total;
        final total = subtotal + costoEnvio;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _encabezado(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _seccionResumen(carritoProvider),
                      const SizedBox(height: 18),
                      _seccionEntrega(),
                      const SizedBox(height: 18),
                      _seccionPago(),
                      const SizedBox(height: 18),
                      _seccionObservacion(),
                      const SizedBox(height: 18),
                      _seccionTotales(
                        subtotal: subtotal,
                        total: total,
                      ),
                    ],
                  ),
                ),
                _botonConfirmar(),
              ],
            ),
          ),
        );
      },
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
            onPressed: _cargando
                ? null
                : () {
                    Navigator.pop(context);
                  },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              "Confirmar pedido",
              style: TextStyle(
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

  Widget _seccionResumen(CarritoProvider carritoProvider) {
    return _contenedor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion("Resumen del pedido"),
          const SizedBox(height: 12),
          ...carritoProvider.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${item.cantidad} x ${item.producto.nombre}",
                      style: TextStyle(
                        color: colorTexto,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    "L. ${item.subtotal.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: colorTexto,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _seccionEntrega() {
    return _contenedor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _tituloSeccion("Dirección de entrega")),
              TextButton.icon(
                onPressed: _irAAgregarDireccion,
                icon: Icon(Icons.add, color: colorPrincipal, size: 18),
                label: Text(
                  "Agregar",
                  style: TextStyle(
                    color: colorPrincipal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FutureBuilder<List<Direccion>>(
            future: _direccionesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(color: colorPrincipal),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                );
              }

              final direcciones = snapshot.data ?? [];

              if (direcciones.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          color: colorPrincipal,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "No tienes direcciones guardadas",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Agrega una dirección para poder continuar con tu pedido.",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                );
              }

              return Column(
                children: direcciones.map((direccion) {
                  final seleccionada =
                      _direccionSeleccionada?.idDireccion == direccion.idDireccion;

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        _direccionSeleccionada = direccion;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: seleccionada
                            ? colorPrincipal.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: seleccionada ? colorPrincipal : Colors.black12,
                          width: seleccionada ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            seleccionada
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: seleccionada ? colorPrincipal : Colors.black38,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  direccion.titulo.isEmpty
                                      ? "Dirección"
                                      : direccion.titulo,
                                  style: TextStyle(
                                    color: colorTexto,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  direccion.direccion,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _seccionPago() {
    return _contenedor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion("Método de pago"),
          const SizedBox(height: 8),
          RadioListTile<String>(
            value: "efectivo",
            groupValue: _metodoPago,
            activeColor: colorPrincipal,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Efectivo",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text("Pagar al recibir el pedido"),
            onChanged: (value) {
              setState(() {
                _metodoPago = value!;
              });
            },
          ),
          RadioListTile<String>(
            value: "tarjeta",
            groupValue: _metodoPago,
            activeColor: colorPrincipal,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Tarjeta",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text("Pago con tarjeta al recibir"),
            onChanged: (value) {
              setState(() {
                _metodoPago = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _seccionObservacion() {
    return _contenedor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tituloSeccion("Observación"),
          const SizedBox(height: 12),
          TextField(
            controller: _observacionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Ejemplo: entregar en la entrada principal",
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _seccionTotales({
    required double subtotal,
    required double total,
  }) {
    return _contenedor(
      child: Column(
        children: [
          _filaTotal(
            titulo: "Subtotal",
            valor: "L. ${subtotal.toStringAsFixed(2)}",
            destacado: false,
          ),
          const SizedBox(height: 8),
          _filaTotal(
            titulo: "Envío",
            valor: "L. ${costoEnvio.toStringAsFixed(2)}",
            destacado: false,
          ),
          const Divider(height: 24),
          _filaTotal(
            titulo: "Total",
            valor: "L. ${total.toStringAsFixed(2)}",
            destacado: true,
          ),
        ],
      ),
    );
  }

  Widget _botonConfirmar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xfff2f1f4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: _cargando ? null : _confirmarPedido,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrincipal,
            disabledBackgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _cargando
              ? const SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Text(
                  "Confirmar pedido",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _filaTotal({
    required String titulo,
    required String valor,
    required bool destacado,
  }) {
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