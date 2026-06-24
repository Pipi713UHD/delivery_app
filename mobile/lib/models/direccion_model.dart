class Direccion {
  final int idDireccion;
  final int idCliente;
  final String titulo;
  final String direccion;
  final String referencia;
  final double? latitud;
  final double? longitud;
  final bool principal;
  final int estado;

  Direccion({
    required this.idDireccion,
    required this.idCliente,
    required this.titulo,
    required this.direccion,
    required this.referencia,
    this.latitud,
    this.longitud,
    required this.principal,
    required this.estado,
  });

  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      idDireccion: int.tryParse(json["id_direccion"].toString()) ?? 0,
      idCliente: int.tryParse(json["id_cliente"].toString()) ?? 0,
      titulo: json["titulo"]?.toString() ?? "",
      direccion: json["direccion"]?.toString() ?? "",
      referencia: json["referencia"]?.toString() ?? "",
      latitud: json["latitud"] == null
          ? null
          : double.tryParse(json["latitud"].toString()),
      longitud: json["longitud"] == null
          ? null
          : double.tryParse(json["longitud"].toString()),
      principal: int.tryParse((json["principal"] ?? 0).toString()) == 1,
      estado: int.tryParse((json["estado"] ?? 1).toString()) ?? 1,
    );
  }
}
