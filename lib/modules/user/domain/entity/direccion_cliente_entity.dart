class DireccionClienteEntity {
  final int? idDireccion;
  final String? identificacion;
  final String nombreDireccion;
  final String? direccion;
  final String? referencia;
  final bool? esPrincipal;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;
  final String estado;

  DireccionClienteEntity({
    this.idDireccion,
    this.identificacion,
    required this.nombreDireccion,
    this.direccion,
    this.referencia,
    this.esPrincipal,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
    required this.estado,
  });

  /// Factory constructor desde JSON de la base de datos
  factory DireccionClienteEntity.fromJson(Map<String, dynamic> json) {
    return DireccionClienteEntity(
      idDireccion: json['IDDIRECCION'],
      identificacion: json['IDENTIFICACION'],
      nombreDireccion: json['NOMBRE_DIRECCION'] ?? '',
      direccion: json['DIRECCION'],
      referencia: json['REFERENCIA'],
      esPrincipal: json['ES_PRINCIPAL'],
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
      estado: json['ESTADO'] ?? 'ACTIVO',
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDDIRECCION': idDireccion,
      'IDENTIFICACION': identificacion,
      'NOMBRE_DIRECCION': nombreDireccion,
      'DIRECCION': direccion,
      'REFERENCIA': referencia,
      'ES_PRINCIPAL': esPrincipal,
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
      'idDireccion': idDireccion,
      'identificacion': identificacion,
      'nombreDireccion': nombreDireccion,
      'direccion': direccion,
      'referencia': referencia,
      'esPrincipal': esPrincipal,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
      'estado': estado,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  DireccionClienteEntity copyWith({
    int? idDireccion,
    String? identificacion,
    String? nombreDireccion,
    String? direccion,
    String? referencia,
    bool? esPrincipal,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
    String? estado,
  }) {
    return DireccionClienteEntity(
      idDireccion: idDireccion ?? this.idDireccion,
      identificacion: identificacion ?? this.identificacion,
      nombreDireccion: nombreDireccion ?? this.nombreDireccion,
      direccion: direccion ?? this.direccion,
      referencia: referencia ?? this.referencia,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
      estado: estado ?? this.estado,
    );
  }

  /// Verifica si la dirección está activa
  bool get isActiva => estado.toUpperCase() == 'ACTIVO';

  /// Verifica si la dirección está inactiva
  bool get isInactiva => estado.toUpperCase() == 'INACTIVO';

  /// Verifica si es la dirección principal
  bool get esPrincipalDireccion => esPrincipal == true;

  /// Verifica si tiene dirección completa
  bool get tieneDireccionCompleta => direccion != null && direccion!.isNotEmpty;

  /// Verifica si tiene referencia
  bool get tieneReferencia => referencia != null && referencia!.isNotEmpty;

  /// Obtiene la dirección completa formateada
  String get direccionCompleta {
    List<String> partes = [];

    if (direccion != null && direccion!.isNotEmpty) {
      partes.add(direccion!);
    }

    if (referencia != null && referencia!.isNotEmpty) {
      partes.add('Ref: $referencia');
    }

    return partes.join(', ');
  }

  /// Obtiene la dirección resumida (primeros 50 caracteres)
  String get direccionResumida {
    final completa = direccionCompleta;
    if (completa.length <= 50) return completa;
    return '${completa.substring(0, 50)}...';
  }

  /// Obtiene el estado con formato
  String get estadoFormateado {
    return estado.toUpperCase();
  }

  /// Obtiene el color del estado para la UI
  String get colorEstado {
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return 'verde';
      case 'INACTIVO':
        return 'gris';
      default:
        return 'gris';
    }
  }

  /// Obtiene el icono del estado para la UI
  String get iconoEstado {
    switch (estado.toUpperCase()) {
      case 'ACTIVO':
        return 'check_circle';
      case 'INACTIVO':
        return 'pause_circle';
      default:
        return 'help';
    }
  }

  /// Obtiene el icono para dirección principal
  String get iconoPrincipal {
    return esPrincipalDireccion ? 'home' : 'location_on';
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

  /// Verifica si fue modificada
  bool get fueModificada => fModificacion != null;

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

  /// Obtiene la información completa para mostrar
  String get informacionCompleta {
    List<String> info = [nombreDireccion];

    if (direccionCompleta.isNotEmpty) {
      info.add(direccionCompleta);
    }

    if (esPrincipalDireccion) {
      info.add('(Principal)');
    }

    return info.join(' - ');
  }

  @override
  String toString() {
    return 'DireccionClienteEntity(idDireccion: $idDireccion, nombre: $nombreDireccion, principal: $esPrincipal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DireccionClienteEntity &&
        other.idDireccion == idDireccion &&
        other.identificacion == identificacion &&
        other.nombreDireccion == nombreDireccion;
  }

  @override
  int get hashCode {
    return Object.hash(
      idDireccion,
      identificacion,
      nombreDireccion,
    );
  }
}
