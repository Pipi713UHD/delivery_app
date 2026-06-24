class Usuario {
  final int idUsuario;
  final int idRol;
  final String rol;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final int estado;

  final int? idCliente;
  final int? idRepartidor;
  final int? idRestaurante;

  Usuario({
    required this.idUsuario,
    required this.idRol,
    required this.rol,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.estado,
    this.idCliente,
    this.idRepartidor,
    this.idRestaurante,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: int.tryParse(json["id_usuario"].toString()) ?? 0,
      idRol: int.tryParse(json["id_rol"].toString()) ?? 0,
      rol: json["rol"]?.toString().toLowerCase() ?? "",
      nombre: json["nombre"]?.toString() ?? "",
      apellido: json["apellido"]?.toString() ?? "",
      correo: json["correo"]?.toString() ?? "",
      telefono: json["telefono"]?.toString() ?? "",
      estado: int.tryParse(json["estado"].toString()) ?? 0,
      idCliente: json["id_cliente"] == null
          ? null
          : int.tryParse(json["id_cliente"].toString()),
      idRepartidor: json["id_repartidor"] == null
          ? null
          : int.tryParse(json["id_repartidor"].toString()),
      idRestaurante: json["id_restaurante"] == null
          ? null
          : int.tryParse(json["id_restaurante"].toString()),
    );
  }

  String get nombreCompleto {
    return "$nombre $apellido".trim();
  }
}