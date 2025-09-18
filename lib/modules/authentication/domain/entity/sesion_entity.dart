class SesionEntity {
  final String? idSesion;
  final int idUsuario;
  final String? token;
  final DateTime? fCreacion;
  final DateTime? fExpiracion;
  final bool? activo;

  SesionEntity({
    this.idSesion,
    required this.idUsuario,
    this.token,
    this.fCreacion,
    this.fExpiracion,
    this.activo,
  });

  /// Factory constructor desde JSON de la base de datos
  factory SesionEntity.fromJson(Map<String, dynamic> json) {
    return SesionEntity(
      idSesion: json['IDSESION'],
      idUsuario: json['IDUSUARIO'] ?? 0,
      token: json['TOKEN'],
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fExpiracion: json['FEXPIRACION'] != null
          ? DateTime.parse(json['FEXPIRACION'])
          : null,
      activo: json['ACTIVO'],
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDSESION': idSesion,
      'IDUSUARIO': idUsuario,
      'TOKEN': token,
      'FCREACION': fCreacion?.toIso8601String(),
      'FEXPIRACION': fExpiracion?.toIso8601String(),
      'ACTIVO': activo,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idSesion': idSesion,
      'idUsuario': idUsuario,
      'token': token,
      'fCreacion': fCreacion?.toIso8601String(),
      'fExpiracion': fExpiracion?.toIso8601String(),
      'activo': activo,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  SesionEntity copyWith({
    String? idSesion,
    int? idUsuario,
    String? token,
    DateTime? fCreacion,
    DateTime? fExpiracion,
    bool? activo,
  }) {
    return SesionEntity(
      idSesion: idSesion ?? this.idSesion,
      idUsuario: idUsuario ?? this.idUsuario,
      token: token ?? this.token,
      fCreacion: fCreacion ?? this.fCreacion,
      fExpiracion: fExpiracion ?? this.fExpiracion,
      activo: activo ?? this.activo,
    );
  }

  /// Verifica si la sesión está activa
  bool get isActiva => activo == true;

  /// Verifica si la sesión está expirada
  bool get isExpirada {
    if (fExpiracion == null) return true;
    return DateTime.now().isAfter(fExpiracion!);
  }

  /// Verifica si la sesión es válida (activa y no expirada)
  bool get esValida => isActiva && !isExpirada;

  /// Verifica si tiene token
  bool get tieneToken => token != null && token!.isNotEmpty;

  /// Obtiene el tiempo restante hasta la expiración
  Duration? get tiempoRestante {
    if (fExpiracion == null) return null;
    final ahora = DateTime.now();
    if (ahora.isAfter(fExpiracion!)) return Duration.zero;
    return fExpiracion!.difference(ahora);
  }

  /// Obtiene el tiempo restante formateado
  String get tiempoRestanteFormateado {
    final tiempo = tiempoRestante;
    if (tiempo == null) return 'Sin expiración';
    if (tiempo == Duration.zero) return 'Expirada';

    if (tiempo.inHours > 0) {
      return '${tiempo.inHours}h ${tiempo.inMinutes % 60}m';
    } else if (tiempo.inMinutes > 0) {
      return '${tiempo.inMinutes}m';
    } else {
      return '${tiempo.inSeconds}s';
    }
  }

  /// Obtiene la fecha de creación formateada
  String get fechaCreacionFormateada {
    if (fCreacion == null) return 'Sin fecha';
    return '${fCreacion!.day.toString().padLeft(2, '0')}/${fCreacion!.month.toString().padLeft(2, '0')}/${fCreacion!.year}';
  }

  /// Obtiene la fecha de expiración formateada
  String get fechaExpiracionFormateada {
    if (fExpiracion == null) return 'Sin expiración';
    return '${fExpiracion!.day.toString().padLeft(2, '0')}/${fExpiracion!.month.toString().padLeft(2, '0')}/${fExpiracion!.year}';
  }

  /// Obtiene el estado de la sesión
  String get estadoSesion {
    if (!isActiva) return 'INACTIVA';
    if (isExpirada) return 'EXPIRADA';
    return 'ACTIVA';
  }

  /// Obtiene el color del estado para la UI
  String get colorEstado {
    switch (estadoSesion) {
      case 'ACTIVA':
        return 'verde';
      case 'EXPIRADA':
        return 'rojo';
      case 'INACTIVA':
        return 'gris';
      default:
        return 'gris';
    }
  }

  /// Obtiene el icono del estado para la UI
  String get iconoEstado {
    switch (estadoSesion) {
      case 'ACTIVA':
        return 'check_circle';
      case 'EXPIRADA':
        return 'schedule';
      case 'INACTIVA':
        return 'pause_circle';
      default:
        return 'help';
    }
  }

  /// Obtiene el token truncado para mostrar
  String get tokenTruncado {
    if (token == null || token!.isEmpty) return 'Sin token';
    if (token!.length <= 8) return token!;
    return '${token!.substring(0, 8)}...';
  }

  /// Verifica si la sesión está próxima a expirar (menos de 30 minutos)
  bool get proximaAExpirar {
    final tiempo = tiempoRestante;
    if (tiempo == null) return false;
    return tiempo.inMinutes < 30 && tiempo.inMinutes > 0;
  }

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
      return 'Recién creada';
    }
  }

  @override
  String toString() {
    return 'SesionEntity(idSesion: $idSesion, idUsuario: $idUsuario, estado: $estadoSesion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SesionEntity &&
        other.idSesion == idSesion &&
        other.idUsuario == idUsuario &&
        other.token == token;
  }

  @override
  int get hashCode {
    return Object.hash(
      idSesion,
      idUsuario,
      token,
    );
  }
}
