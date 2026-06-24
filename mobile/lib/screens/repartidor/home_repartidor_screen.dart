import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'pedidos_disponibles_screen.dart';
import 'entregas_screen.dart';

class HomeRepartidorScreen extends StatefulWidget {
  const HomeRepartidorScreen({super.key});

  @override
  State<HomeRepartidorScreen> createState() => _HomeRepartidorScreenState();
}

class _HomeRepartidorScreenState extends State<HomeRepartidorScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  int _paginaActual = 0;

  final List<Widget> _paginas = const [
    PedidosDisponiblesScreen(),
    EntregasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final usuario = authProvider.usuario;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _encabezado(
              context,
              usuario?.nombreCompleto ?? "Repartidor",
              authProvider,
            ),
            Expanded(
              child: _paginas[_paginaActual],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        selectedItemColor: colorPrincipal,
        unselectedItemColor: colorTexto,
        onTap: (index) {
          setState(() {
            _paginaActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: "Disponibles",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_outlined),
            activeIcon: Icon(Icons.delivery_dining),
            label: "Mis entregas",
          ),
        ],
      ),
    );
  }

  Widget _encabezado(
    BuildContext context,
    String nombre,
    AuthProvider authProvider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
      decoration: BoxDecoration(
        color: colorPrincipal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.delivery_dining,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Panel repartidor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              authProvider.cerrarSesion();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}