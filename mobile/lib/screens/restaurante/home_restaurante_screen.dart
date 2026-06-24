import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'pedidos_restaurante_screen.dart';

class HomeRestauranteScreen extends StatelessWidget {
  const HomeRestauranteScreen({super.key});

  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

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
              usuario?.nombreCompleto ?? "Restaurante",
              authProvider,
            ),
            const Expanded(
              child: PedidosRestauranteScreen(),
            ),
          ],
        ),
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
            Icons.storefront_outlined,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Panel restaurante",
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