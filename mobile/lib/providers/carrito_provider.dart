import 'package:flutter/material.dart';

import '../models/carrito_model.dart';
import '../models/producto_model.dart';

class CarritoProvider extends ChangeNotifier {
  final List<CarritoItem> _items = [];

  List<CarritoItem> get items => _items;

  bool get estaVacio => _items.isEmpty;

  int get totalProductos {
    int total = 0;

    for (final item in _items) {
      total += item.cantidad;
    }

    return total;
  }

  double get total {
    double suma = 0;

    for (final item in _items) {
      suma += item.subtotal;
    }

    return suma;
  }

  void agregarProducto(Producto producto) {
    final index = _items.indexWhere(
      (item) => item.producto.nombre == producto.nombre,
    );

    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(
        CarritoItem(
          producto: producto,
          cantidad: 1,
        ),
      );
    }

    notifyListeners();
  }

  void aumentarCantidad(CarritoItem item) {
    item.cantidad++;
    notifyListeners();
  }

  void disminuirCantidad(CarritoItem item) {
    if (item.cantidad > 1) {
      item.cantidad--;
    } else {
      _items.remove(item);
    }

    notifyListeners();
  }

  void eliminarProducto(CarritoItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }
}