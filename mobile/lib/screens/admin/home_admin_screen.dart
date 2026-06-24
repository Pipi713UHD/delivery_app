import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'restaurantes_admin_screen.dart';
import 'usuarios_admin_screen.dart';
import 'pedidos_admin_screen.dart';
import 'productos_admin_screen.dart';
import 'repartidores_admin_screen.dart';

class HomeAdminScreen extends StatelessWidget {
  const HomeAdminScreen({super.key});

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
            _encabezado(context, authProvider, usuario?.nombreCompleto ?? "Administrador"),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _tarjetaBienvenida(usuario?.nombreCompleto ?? "Administrador"),
                  const SizedBox(height: 18),
                  _opcionAdmin(
                    icono: Icons.storefront_outlined,
                    titulo: "Restaurantes",
                    subtitulo: "Administrar restaurantes registrados",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantesAdminScreen()));
                    },
                  ),
                  _opcionAdmin(
                    icono: Icons.fastfood_outlined,
                    titulo: "Productos",
                    subtitulo: "Crear, editar y desactivar productos",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductosAdminScreen(),
                        ),
                      );
                    },
                  ),
                  _opcionAdmin(
                    icono: Icons.receipt_long_outlined,
                    titulo: "Pedidos",
                    subtitulo: "Ver todos los pedidos del sistema",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PedidosAdminScreen()));
                    },
                  ),
                  _opcionAdmin(
                    icono: Icons.people_alt_outlined,
                    titulo: "Usuarios",
                    subtitulo: "Administrar clientes, repartidores y locales",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UsuariosAdminScreen(tipo: 'cliente')));
                    },
                  ),
                  _opcionAdmin(
                    icono: Icons.delivery_dining,
                    titulo: "Repartidores",
                    subtitulo: "Ver y administrar repartidores",
                    onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RepartidoresAdminScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(
    BuildContext context,
    AuthProvider authProvider,
    String nombre,
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
            Icons.admin_panel_settings_outlined,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Panel administrador",
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

  Widget _tarjetaBienvenida(String nombre) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 33,
            backgroundColor: const Color(0xffffd6e6),
            child: Icon(
              Icons.person_outline,
              color: colorPrincipal,
              size: 38,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenido, $nombre",
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Desde aquí podrás administrar la app de delivery.",
                  style: TextStyle(
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

  Widget _opcionAdmin({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xffffd6e6),
          child: Icon(
            icono,
            color: colorPrincipal,
          ),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: colorTexto,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }

  void _mensajePendiente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Esta sección la construiremos más adelante"),
        duration: Duration(seconds: 1),
      ),
    );
  }
}