class TUsuariEntity {
  final int idUsuario;
  final int idSucursal;
  final String identificacion;
  final String? usuario;
  final String? password;
  final bool? temporal;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  TUsuariEntity({
    required this.idUsuario,
    required this.idSucursal,
    required this.identificacion,
    this.usuario,
    this.password,
    this.temporal,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory para construir desde JSON (Supabase/DB)
  factory TUsuariEntity.fromJson(Map<String, dynamic> json) {
    return TUsuariEntity(
      idUsuario: json['IDUSUARIO'] as int,
      idSucursal: json['IDSUCURSAL'] as int,
      identificacion: json['IDENTIFICACION'] as String,
      usuario: json['USUARIO'],
      password: json['PASSWORD'],
      temporal: json['TEMPORAL'],
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
    );
  }

  /// Convertir a JSON (para insert/update en Supabase)
  Map<String, dynamic> toJson() {
    return {
      'IDUSUARIO': idUsuario,
      'IDSUCURSAL': idSucursal,
      'IDENTIFICACION': identificacion,
      'USUARIO': usuario,
      'PASSWORD': password,
      'TEMPORAL': temporal,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
    };
  }
}
