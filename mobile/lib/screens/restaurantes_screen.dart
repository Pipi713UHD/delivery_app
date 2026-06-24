import 'package:flutter/material.dart';

import '../models/restaurante_model.dart';
import '../services/restaurante_service.dart';

class RestaurantesScreen extends StatefulWidget {
  const RestaurantesScreen({super.key});

  @override
  State<RestaurantesScreen> createState() => _RestaurantesScreenState();
}

class _RestaurantesScreenState extends State<RestaurantesScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final RestauranteService _service = RestauranteService();
  late Future<List<Restaurante>> _restaurantesFuture;

  @override
  void initState() {
    super.initState();
    _restaurantesFuture = _service.listarRestaurantes();
  }

  Future<void> _recargar() async {
    setState(() {
      _restaurantesFuture = _service.listarRestaurantes();
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
              child: FutureBuilder<List<Restaurante>>(
                future: _restaurantesFuture,
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

                  final restaurantes = snapshot.data ?? [];

                  if (restaurantes.isEmpty) {
                    return const Center(
                      child: Text("No hay restaurantes disponibles"),
                    );
                  }

                  return RefreshIndicator(
                    color: colorPrincipal,
                    onRefresh: _recargar,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: restaurantes.length,
                      itemBuilder: (context, index) {
                        final restaurante = restaurantes[index];
                        return _restauranteCard(restaurante);
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
              const Expanded(
                child: Text(
                  "Restaurantes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 30,
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
                      hintText: "Buscar restaurantes",
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

  Widget _restauranteCard(Restaurante restaurante) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xfff5f4f6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          // Aquí después abriremos la pantalla de productos.
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 145,
              decoration: const BoxDecoration(
                color: Color(0xffffd6e6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant_menu,
                  color: Color(0xffe9004f),
                  size: 75,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurante.nombre,
                    style: TextStyle(
                      color: colorTexto,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    restaurante.descripcion,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurante.calificacion,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.delivery_dining,
                        color: colorPrincipal,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "L. ${restaurante.costoEnvio}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        color: Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "30-45 min",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    restaurante.categoria,
                    style: TextStyle(
                      color: colorPrincipal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}