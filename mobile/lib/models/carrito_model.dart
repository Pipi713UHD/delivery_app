import 'producto_model.dart';

class CarritoItem {
  final Producto producto;
  int cantidad;

  CarritoItem({
    required this.producto,
    required this.cantidad,
  });

  double get precioUnitario {
    return double.tryParse(producto.precio.toString()) ?? 0.0;
  }

  double get subtotal {
    return precioUnitario * cantidad;
  }
}