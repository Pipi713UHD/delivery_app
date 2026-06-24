import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/producto_model.dart';
import '../../services/producto_service.dart';
import '../../providers/carrito_provider.dart';
import 'carrito_screen.dart';

class ProductosScreen extends StatefulWidget {
  final String idRestaurante;
  final String nombreRestaurante;

  const ProductosScreen({
    super.key,
    required this.idRestaurante,
    required this.nombreRestaurante,
  });

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final ProductoService _productoService = ProductoService();

  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = _productoService.listarPorRestaurante(
      widget.idRestaurante,
    );
  }

  Future<void> _recargar() async {
    setState(() {
      _productosFuture = _productoService.listarPorRestaurante(
        widget.idRestaurante,
      );
    });
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
              child: FutureBuilder<List<Producto>>(
                future: _productosFuture,
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

                  final productos = snapshot.data ?? [];

                  if (productos.isEmpty) {
                    return _sinProductos();
                  }

                  return RefreshIndicator(
                    color: colorPrincipal,
                    onRefresh: _recargar,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return _productoCard(producto);
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
      child: Column(
        children: [
          Row(
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
                  widget.nombreRestaurante,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Consumer<CarritoProvider>(
                builder: (context, carritoProvider, child) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarritoScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        if (carritoProvider.totalProductos > 0)
                          Positioned(
                            right: -8,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                carritoProvider.totalProductos.toString(),
                                style: TextStyle(
                                  color: colorPrincipal,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 55,
            padding: const EdgeInsets.only(left: 18, right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Buscar productos",
                      hintStyle: TextStyle(
                        color: Color(0xff7b7484),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: colorPrincipal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinProductos() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood_outlined,
              color: colorPrincipal,
              size: 85,
            ),
            const SizedBox(height: 18),
            Text(
              "No hay productos disponibles",
              style: TextStyle(
                color: colorTexto,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Este restaurante todavía no tiene productos activos.",
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

  Widget _productoCard(Producto producto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          context.read<CarritoProvider>().agregarProducto(producto);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${producto.nombre} agregado al carrito"),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  color: const Color(0xffffd6e6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.fastfood,
                  color: colorPrincipal,
                  size: 50,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: TextStyle(
                        color: colorTexto,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      producto.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      producto.categoria,
                      style: TextStyle(
                        color: colorPrincipal,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "L. ${producto.precio}",
                      style: TextStyle(
                        color: colorTexto,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: () {
                  context.read<CarritoProvider>().agregarProducto(producto);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${producto.nombre} agregado al carrito"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorPrincipal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}