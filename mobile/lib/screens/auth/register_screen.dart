import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmarPasswordController =
      TextEditingController();

  bool _ocultarPassword = true;
  bool _ocultarConfirmar = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final ok = await authProvider.registrar(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      correo: _correoController.text.trim(),
      telefono: _telefonoController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? "No se pudo crear la cuenta"),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cuenta creada correctamente. Ya puedes iniciar sesión."),
      ),
    );

    Navigator.pop(context);
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Regístrate para empezar a pedir",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tus datos",
                            style: TextStyle(
                              color: colorTexto,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Completa el formulario para registrarte",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _inputTexto(
                                  controller: _nombreController,
                                  label: "Nombre",
                                  icono: Icons.badge_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _inputTexto(
                                  controller: _apellidoController,
                                  label: "Apellido",
                                  icono: Icons.badge_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _inputTexto(
                            controller: _correoController,
                            label: "Correo",
                            icono: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (valor) {
                              if (valor == null || valor.trim().isEmpty) {
                                return "Ingrese su correo";
                              }
                              if (!valor.contains("@") ||
                                  !valor.contains(".")) {
                                return "Ingrese un correo válido";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _inputTexto(
                            controller: _telefonoController,
                            label: "Teléfono",
                            icono: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _inputPassword(
                            controller: _passwordController,
                            label: "Contraseña",
                            ocultar: _ocultarPassword,
                            onToggle: () {
                              setState(() {
                                _ocultarPassword = !_ocultarPassword;
                              });
                            },
                            validator: (valor) {
                              if (valor == null || valor.isEmpty) {
                                return "Ingrese una contraseña";
                              }
                              if (valor.length < 6) {
                                return "Mínimo 6 caracteres";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _inputPassword(
                            controller: _confirmarPasswordController,
                            label: "Confirmar contraseña",
                            ocultar: _ocultarConfirmar,
                            onToggle: () {
                              setState(() {
                                _ocultarConfirmar = !_ocultarConfirmar;
                              });
                            },
                            validator: (valor) {
                              if (valor != _passwordController.text) {
                                return "Las contraseñas no coinciden";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed:
                                  authProvider.cargando ? null : _registrar,
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
                                      "Crear cuenta",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "¿Ya tienes cuenta? Inicia sesión",
                                style: TextStyle(
                                  color: colorPrincipal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _inputTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ??
          (valor) {
            if (valor == null || valor.trim().isEmpty) {
              return "Campo obligatorio";
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icono,
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

  Widget _inputPassword({
    required TextEditingController controller,
    required String label,
    required bool ocultar,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: ocultar,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: colorPrincipal,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
