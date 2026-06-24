import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home_screen.dart';
import '../admin/home_admin_screen.dart';
import '../repartidor/home_repartidor_screen.dart';
import '../restaurante/home_restaurante_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _ocultarPassword = true;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingrese correo y contraseña"),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final ok = await authProvider.login(
      correo: correo,
      password: password,
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? "No se pudo iniciar sesión"),
        ),
      );
      return;
    }

    final usuario = authProvider.usuario;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se encontró información del usuario"),
        ),
      );
      return;
    }

    if (usuario.rol == "cliente") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else if (usuario.rol == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeAdminScreen(),
        ),
      );
    } else if (usuario.rol == "repartidor") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeRepartidorScreen(),
        ),
      );
    } else if (usuario.rol == "restaurante") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeRestauranteScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Rol no reconocido: ${usuario.rol}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrincipal,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 45),
                  const Icon(
                    Icons.delivery_dining,
                    color: Colors.white,
                    size: 95,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Delivery App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Inicia sesión para continuar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 35),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bienvenido",
                          style: TextStyle(
                            color: colorTexto,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Ingrese sus credenciales",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _inputCorreo(),
                        const SizedBox(height: 16),
                        _inputPassword(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed:
                                authProvider.cargando ? null : _iniciarSesion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorPrincipal,
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: authProvider.cargando
                                ? const SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "Iniciar sesión",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                                children: [
                                  const TextSpan(text: "¿No tienes cuenta? "),
                                  TextSpan(
                                    text: "Regístrate",
                                    style: TextStyle(
                                      color: colorPrincipal,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _inputCorreo() {
    return TextField(
      controller: _correoController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Correo",
        prefixIcon: Icon(
          Icons.email_outlined,
          color: colorPrincipal,
        ),
        filled: true,
        fillColor: const Color(0xfff2f1f4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _inputPassword() {
    return TextField(
      controller: _passwordController,
      obscureText: _ocultarPassword,
      decoration: InputDecoration(
        labelText: "Contraseña",
        prefixIcon: Icon(
          Icons.lock_outline,
          color: colorPrincipal,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _ocultarPassword = !_ocultarPassword;
            });
          },
          icon: Icon(
            _ocultarPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        filled: true,
        fillColor: const Color(0xfff2f1f4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}