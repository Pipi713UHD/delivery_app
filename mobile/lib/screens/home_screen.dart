import 'package:flutter/material.dart';

import 'cliente/mis_pedidos_screen.dart';
import 'cliente/perfil_cliente_screen.dart';
import 'cliente/productos_screen.dart';
import 'cliente/carrito_screen.dart';
import '../models/restaurante_model.dart';
import '../services/restaurante_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaActual = 0;

  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final RestauranteService _restauranteService = RestauranteService();
  late Future<List<Restaurante>> _restaurantesFuture;

  @override
  void initState() {
    super.initState();
    _restaurantesFuture = _restauranteService.listarRestaurantes();
  }

  Future<void> _recargarRestaurantes() async {
    setState(() {
      _restaurantesFuture = _restauranteService.listarRestaurantes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _obtenerPantalla(),
      bottomNavigationBar: _menuInferior(),
    );
  }

  Widget _obtenerPantalla() {
    switch (_paginaActual) {
      case 0:
        return _inicio();
      case 1:
        return _promocionesScreen();
      case 2:
        return const MisPedidosScreen();
      case 3:
        return const PerfilClienteScreen();
      default:
        return _inicio();
    }
  }

  Widget _inicio() {
    return Column(
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
                return _sinRestaurantes();
              }

              return RefreshIndicator(
                color: colorPrincipal,
                onRefresh: _recargarRestaurantes,
                child: ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: restaurantes.length,
                  itemBuilder: (context, index) {
                    return _restauranteCard(restaurantes[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 45, 22, 30),
      decoration: BoxDecoration(
        color: colorPrincipal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Flexible(
                      child: Text(
                        "Unnamed Road",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                    size: 33,
                  ),
                  Positioned(
                    right: 2,
                    top: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 22),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarritoScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            height: 64,
            padding: const EdgeInsets.only(left: 22, right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Locales, platos y productos",
                      hintStyle: TextStyle(
                        color: Color(0xff7b7484),
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colorPrincipal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinRestaurantes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              color: colorPrincipal,
              size: 85,
            ),
            const SizedBox(height: 18),
            Text(
              "No hay restaurantes disponibles",
              style: TextStyle(
                color: colorTexto,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cuando haya restaurantes activos, aparecerán aquí.",
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

  Widget _restauranteCard(Restaurante restaurante) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductosScreen(
                idRestaurante: restaurante.idRestaurante,
                nombreRestaurante: restaurante.nombre,
              ),
            ),
          );
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

  Widget _promocionesScreen() {
    return SafeArea(
      child: Column(
        children: [
          _headerSimple("Promociones"),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _promoCard(
                  titulo: "BIENVENIDO10",
                  descripcion: "Obtén 10% de descuento en tu primer pedido.",
                  icono: Icons.percent,
                ),
                _promoCard(
                  titulo: "Envío especial",
                  descripcion: "Promociones disponibles en restaurantes seleccionados.",
                  icono: Icons.delivery_dining,
                ),
                _promoCard(
                  titulo: "Combos destacados",
                  descripcion: "Ahorra comprando combos de comida rápida.",
                  icono: Icons.fastfood,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerSimple(String titulo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      decoration: BoxDecoration(
        color: colorPrincipal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _promoCard({
    required String titulo,
    required String descripcion,
    required IconData icono,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffffe0ec),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colorPrincipal,
            child: Icon(icono, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuInferior() {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: colorTexto,
        unselectedItemColor: colorTexto,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 32),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.percent, size: 32),
            label: "Promociones",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined, size: 32),
            label: "Pedidos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 32),
            label: "Mi perfil",
          ),
        ],
      ),
    );
  }
}