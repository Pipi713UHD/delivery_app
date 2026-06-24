import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/carrito_provider.dart';
import '../../models/carrito_model.dart';
import 'confirmar_pedido_screen.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<CarritoProvider>(
          builder: (context, carritoProvider, child) {
            return Column(
              children: [
                _encabezado(context, carritoProvider),
                Expanded(
                  child: carritoProvider.estaVacio
                      ? _carritoVacio()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: carritoProvider.items.length,
                          itemBuilder: (context, index) {
                            final item = carritoProvider.items[index];
                            return _itemCarrito(context, item);
                          },
                        ),
                ),
                if (!carritoProvider.estaVacio)
                  _resumenCompra(context, carritoProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _encabezado(
    BuildContext context,
    CarritoProvider carritoProvider,
  ) {
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
          const Expanded(
            child: Text(
              "Mi carrito",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!carritoProvider.estaVacio)
            IconButton(
              onPressed: () {
                carritoProvider.vaciarCarrito();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Carrito vaciado"),
                  ),
                );
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }

  Widget _carritoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              color: colorPrincipal,
              size: 95,
            ),
            const SizedBox(height: 18),
            Text(
              "Tu carrito está vacío",
              style: TextStyle(
                color: colorTexto,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Agrega productos desde un restaurante para verlos aquí.",
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

  Widget _itemCarrito(
    BuildContext context,
    CarritoItem item,
  ) {
    final carritoProvider = context.read<CarritoProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xffffd6e6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.fastfood,
              color: colorPrincipal,
              size: 45,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.producto.nombre,
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.producto.categoria,
                  style: TextStyle(
                    color: colorPrincipal,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "L. ${item.subtotal.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Row(
                children: [
                  _botonCantidad(
                    icono: Icons.remove,
                    onTap: () {
                      carritoProvider.disminuirCantidad(item);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      item.cantidad.toString(),
                      style: TextStyle(
                        color: colorTexto,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _botonCantidad(
                    icono: Icons.add,
                    onTap: () {
                      carritoProvider.aumentarCantidad(item);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  carritoProvider.eliminarProducto(item);
                },
                child: const Text(
                  "Eliminar",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botonCantidad({
    required IconData icono,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: colorPrincipal,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icono,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _resumenCompra(
    BuildContext context,
    CarritoProvider carritoProvider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: const BoxDecoration(
        color: Color(0xfff2f1f4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Productos",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              Text(
                carritoProvider.totalProductos.toString(),
                style: TextStyle(
                  color: colorTexto,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Total",
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "L. ${carritoProvider.total.toStringAsFixed(2)}",
                style: TextStyle(
                  color: colorPrincipal,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfirmarPedidoScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrincipal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Continuar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}