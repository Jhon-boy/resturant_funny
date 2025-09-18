class RolUsuarioEntity {
  final int? idRolUsuario;
  final int idUsuario;
  final int? idRol;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;
  final String? estado;

  RolUsuarioEntity({
    this.idRolUsuario,
    required this.idUsuario,
    this.idRol,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
    this.estado,
  });

  /// Factory constructor desde JSON de la base de datos
  factory RolUsuarioEntity.fromJson(Map<String, dynamic> json) {
    return RolUsuarioEntity(
      idRolUsuario: json['IDROLUSUARIO'],
      idUsuario: json['IDUSUARIO'] ?? 0,
      idRol: json['IDROL'],
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
      estado: json['ESTADO'],
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDROLUSUARIO': idRolUsuario,
      'IDUSUARIO': idUsuario,
      'IDROL': idRol,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
      'ESTADO': estado,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idRolUsuario': idRolUsuario,
      'idUsuario': idUsuario,
      'idRol': idRol,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
      'estado': estado,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  RolUsuarioEntity copyWith({
    int? idRolUsuario,
    int? idUsuario,
    int? idRol,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
    String? estado,
  }) {
    return RolUsuarioEntity(
      idRolUsuario: idRolUsuario ?? this.idRolUsuario,
      idUsuario: idUsuario ?? this.idUsuario,
      idRol: idRol ?? this.idRol,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
      estado: estado ?? this.estado,
    );
  }

  /// Verifica si el rol está activo
  bool get isActivo => estado?.toUpperCase() == 'ACTIVO' || estado == null;

  /// Verifica si el rol está inactivo
  bool get isInactivo => estado?.toUpperCase() == 'INACTIVO';

  /// Verifica si el rol está suspendido
  bool get isSuspendido => estado?.toUpperCase() == 'SUSPENDIDO';

  /// Verifica si tiene rol asignado
  bool get tieneRol => idRol != null;

  /// Obtiene el estado con formato
  String get estadoFormateado {
    if (estado == null) return 'ACTIVO';
    return estado!.toUpperCase();
  }

  /// Obtiene el color del estado para la UI
  String get colorEstado {
    switch (estado?.toUpperCase()) {
      case 'ACTIVO':
        return 'verde';
      case 'INACTIVO':
        return 'gris';
      case 'SUSPENDIDO':
        return 'rojo';
      default:
        return 'verde';
    }
  }

  /// Obtiene el icono del estado para la UI
  String get iconoEstado {
    switch (estado?.toUpperCase()) {
      case 'ACTIVO':
        return 'check_circle';
      case 'INACTIVO':
        return 'pause_circle';
      case 'SUSPENDIDO':
        return 'block';
      default:
        return 'check_circle';
    }
  }

  /// Obtiene la fecha de creación formateada
  String get fechaCreacionFormateada {
    if (fCreacion == null) return 'Sin fecha';
    return '${fCreacion!.day.toString().padLeft(2, '0')}/${fCreacion!.month.toString().padLeft(2, '0')}/${fCreacion!.year}';
  }

  /// Obtiene la fecha de modificación formateada
  String get fechaModificacionFormateada {
    if (fModificacion == null) return 'Sin modificar';
    return '${fModificacion!.day.toString().padLeft(2, '0')}/${fModificacion!.month.toString().padLeft(2, '0')}/${fModificacion!.year}';
  }

  /// Verifica si fue modificado
  bool get fueModificado => fModificacion != null;

  /// Obtiene el tiempo desde la creación
  Duration? get tiempoDesdeCreacion {
    if (fCreacion == null) return null;
    return DateTime.now().difference(fCreacion!);
  }

  /// Obtiene el tiempo desde la creación formateado
  String get tiempoDesdeCreacionFormateado {
    final tiempo = tiempoDesdeCreacion;
    if (tiempo == null) return 'Sin fecha';

    if (tiempo.inDays > 0) {
      return '${tiempo.inDays} días';
    } else if (tiempo.inHours > 0) {
      return '${tiempo.inHours} horas';
    } else if (tiempo.inMinutes > 0) {
      return '${tiempo.inMinutes} minutos';
    } else {
      return 'Recién creado';
    }
  }

  @override
  String toString() {
    return 'RolUsuarioEntity(idRolUsuario: $idRolUsuario, idUsuario: $idUsuario, idRol: $idRol)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RolUsuarioEntity &&
        other.idRolUsuario == idRolUsuario &&
        other.idUsuario == idUsuario &&
        other.idRol == idRol;
  }

  @override
  int get hashCode {
    return Object.hash(
      idRolUsuario,
      idUsuario,
      idRol,
    );
  }
}
