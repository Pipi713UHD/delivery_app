import 'package:flutter/material.dart';

import '../models/usuario_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Usuario? _usuario;
  bool _cargando = false;
  String? _error;

  Usuario? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get error => _error;

  bool get estaLogueado => _usuario != null;

  bool get esCliente => _usuario?.rol == "cliente";
  bool get esAdmin => _usuario?.rol == "admin";
  bool get esRepartidor => _usuario?.rol == "repartidor";
  bool get esRestaurante => _usuario?.rol == "restaurante";

  int? get idUsuario => _usuario?.idUsuario;
  int? get idCliente => _usuario?.idCliente;
  int? get idRepartidor => _usuario?.idRepartidor;
  int? get idRestaurante => _usuario?.idRestaurante;

  Future<bool> login({
    required String correo,
    required String password,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final usuarioLogin = await _authService.login(
        correo: correo,
        password: password,
      );

      _usuario = usuarioLogin;
      _cargando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _usuario = null;
      _error = e.toString().replaceAll("Exception: ", "");
      _cargando = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> registrar({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.registrar(
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        telefono: telefono,
        password: password,
      );

      _cargando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      _cargando = false;
      notifyListeners();

      return false;
    }
  }

  void cerrarSesion() {
    _usuario = null;
    _error = null;
    _cargando = false;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}