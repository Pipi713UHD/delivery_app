class Producto {
  final String idProducto;
  final String idRestaurante;
  final String idCategoriaProducto;
  final String nombre;
  final String descripcion;
  final String precio;
  final String imagen;
  final String disponible;
  final String categoria;

  Producto({
    required this.idProducto,
    required this.idRestaurante,
    required this.idCategoriaProducto,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.disponible,
    required this.categoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json["id_producto"].toString(),
      idRestaurante: json["id_restaurante"].toString(),
      idCategoriaProducto: json["id_categoria_producto"].toString(),
      nombre: json["nombre"] ?? "",
      descripcion: json["descripcion"] ?? "",
      precio: json["precio"].toString(),
      imagen: json["imagen"] ?? "",
      disponible: json["disponible"].toString(),
      categoria: json["categoria"] ?? "",
    );
  }
}