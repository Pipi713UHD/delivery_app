class Restaurante {
  final String idRestaurante;
  final String nombre;
  final String descripcion;
  final String telefono;
  final String correo;
  final String direccion;
  final String? logo;
  final String? portada;
  final String horaApertura;
  final String horaCierre;
  final String costoEnvio;
  final String calificacion;
  final String categoria;
  final int estado;

  Restaurante({
    required this.idRestaurante,
    required this.nombre,
    required this.descripcion,
    required this.telefono,
    required this.correo,
    required this.direccion,
    this.logo,
    this.portada,
    required this.horaApertura,
    required this.horaCierre,
    required this.costoEnvio,
    required this.calificacion,
    required this.categoria,
    required this.estado,
  });

  factory Restaurante.fromJson(Map<String, dynamic> json) {
    return Restaurante(
      idRestaurante: json["id_restaurante"].toString(),
      nombre: json["nombre"] ?? "",
      descripcion: json["descripcion"] ?? "",
      telefono: json["telefono"] ?? "",
      correo: json["correo"] ?? "",
      direccion: json["direccion"] ?? "",
      logo: json["logo"],
      portada: json["portada"],
      horaApertura: json["hora_apertura"] ?? "",
      horaCierre: json["hora_cierre"] ?? "",
      costoEnvio: json["costo_envio"].toString(),
      calificacion: json["calificacion"].toString(),
      categoria: json["categoria"] ?? "",
      estado: int.tryParse((json["estado"] ?? 1).toString()) ?? 1,
    );
  }
}