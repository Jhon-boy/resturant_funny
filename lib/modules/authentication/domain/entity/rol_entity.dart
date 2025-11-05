// ENTIDAD PARA LOS ROLES DE USUARIOS
class RolEntity {
  final int idRol;
  final String codigo;
  final String nombre;
  final DateTime fCreacion;
  final DateTime? fModificacion;
  final String? observacion;
  final String estado;
  final String? usuarioIngreso;
  final String? userModificacion;

  RolEntity({
    required this.idRol,
    required this.codigo,
    required this.nombre,
    required this.fCreacion,
    this.fModificacion,
    this.observacion,
    required this.estado,
    this.usuarioIngreso,
    this.userModificacion,
  });

  factory RolEntity.fromJson(Map<String, dynamic> json) {
    return RolEntity(
      idRol: json['IDROL'],
      codigo: json['CODIGO'] ?? '',
      nombre: json['NOMBRE'] ?? '',
      fCreacion: DateTime.parse(json['FCREACION']),
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      observacion: json['OBSERVACION'],
      estado: json['ESTADO'] ?? '',
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDROL': idRol,
      'CODIGO': codigo,
      'NOMBRE': nombre,
      'FCREACION': fCreacion.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'OBSERVACION': observacion,
      'ESTADO': estado,
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
    };
  }
}
