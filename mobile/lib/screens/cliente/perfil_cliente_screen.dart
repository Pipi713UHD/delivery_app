import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/carrito_provider.dart';
import '../auth/login_screen.dart';
import 'direcciones_screen.dart';

class PerfilClienteScreen extends StatelessWidget {
  const PerfilClienteScreen({super.key});

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
            _encabezado(context),
            Expanded(
              child: usuario == null
                  ? _usuarioNoEncontrado(context)
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _tarjetaUsuario(
                          nombre: usuario.nombreCompleto,
                          correo: usuario.correo,
                          telefono: usuario.telefono,
                          rol: usuario.rol,
                        ),
                        const SizedBox(height: 18),
                        _opcionPerfil(
                          icono: Icons.person_outline,
                          titulo: "Datos personales",
                          subtitulo: "Ver y editar información de tu cuenta",
                          onTap: () {
                            _mensajePendiente(context);
                          },
                        ),
                        _opcionPerfil(
                          icono: Icons.location_on_outlined,
                          titulo: "Mis direcciones",
                          subtitulo: "Administrar direcciones de entrega",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DireccionesScreen(),
                              ),
                            );
                          },
                        ),
                        _opcionPerfil(
                          icono: Icons.receipt_long_outlined,
                          titulo: "Historial de pedidos",
                          subtitulo: "Ver pedidos realizados anteriormente",
                          onTap: () {
                            _mensajePendiente(context);
                          },
                        ),
                        _opcionPerfil(
                          icono: Icons.payment_outlined,
                          titulo: "Métodos de pago",
                          subtitulo: "Administrar pagos y tarjetas",
                          onTap: () {
                            _mensajePendiente(context);
                          },
                        ),
                        _opcionPerfil(
                          icono: Icons.notifications_none_outlined,
                          titulo: "Notificaciones",
                          subtitulo: "Configurar avisos de la app",
                          onTap: () {
                            _mensajePendiente(context);
                          },
                        ),
                        _opcionPerfil(
                          icono: Icons.help_outline,
                          titulo: "Ayuda y soporte",
                          subtitulo: "Preguntas frecuentes y contacto",
                          onTap: () {
                            _mensajePendiente(context);
                          },
                        ),
                        const SizedBox(height: 12),
                        _botonCerrarSesion(context),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
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
              "Mi perfil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.account_circle_outlined,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _tarjetaUsuario({
    required String nombre,
    required String correo,
    required String telefono,
    required String rol,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xffffd6e6),
            child: Icon(
              Icons.person,
              color: colorPrincipal,
              size: 48,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre.isEmpty ? "Cliente" : nombre,
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  correo,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  telefono.isEmpty ? "Sin teléfono" : telefono,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorPrincipal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rol.toUpperCase(),
                    style: TextStyle(
                      color: colorPrincipal,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _opcionPerfil({
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

  Widget _botonCerrarSesion(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          _confirmarCerrarSesion(context);
        },
        icon: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
        label: const Text(
          "Cerrar sesión",
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrincipal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _usuarioNoEncontrado(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: colorPrincipal,
              size: 85,
            ),
            const SizedBox(height: 18),
            Text(
              "No hay usuario activo",
              style: TextStyle(
                color: colorTexto,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Inicia sesión nuevamente para ver tu perfil.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _cerrarSesion(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrincipal,
              ),
              child: const Text(
                "Ir al login",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (contextDialog) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Cerrar sesión"),
          content: const Text(
            "¿Seguro que deseas cerrar sesión?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(contextDialog);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(contextDialog);
                _cerrarSesion(context);
              },
              child: Text(
                "Cerrar sesión",
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
  }

  void _cerrarSesion(BuildContext context) {
    context.read<CarritoProvider>().vaciarCarrito();
    context.read<AuthProvider>().cerrarSesion();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
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