class DispositivoEntity {
  final int? idDispositivo;
  final int idUsuario;
  final String? imei;
  final String? marca;
  final String? modelo;
  final DateTime? ultimoAcceso;
  final String? sistemaOperativo;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  DispositivoEntity({
    this.idDispositivo,
    required this.idUsuario,
    this.imei,
    this.marca,
    this.modelo,
    this.ultimoAcceso,
    this.sistemaOperativo,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory DispositivoEntity.fromJson(Map<String, dynamic> json) {
    return DispositivoEntity(
      idDispositivo: json['IDDISPOSITIVO'],
      idUsuario: json['IDUSUARIO'] ?? 0,
      imei: json['IMEI'],
      marca: json['MARCA'],
      modelo: json['MODELO'],
      ultimoAcceso: json['ULTIMOACCESO'] != null
          ? DateTime.parse(json['ULTIMOACCESO'])
          : null,
      sistemaOperativo: json['SISTEMAOPERATIVO'],
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioIngreso: json['USUARIOINGRESO'],
      userModificacion: json['USERMODIFICACION'],
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDDISPOSITIVO': idDispositivo,
      'IDUSUARIO': idUsuario,
      'IMEI': imei,
      'MARCA': marca,
      'MODELO': modelo,
      'ULTIMOACCESO': ultimoAcceso?.toIso8601String(),
      'SISTEMAOPERATIVO': sistemaOperativo,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idDispositivo': idDispositivo,
      'idUsuario': idUsuario,
      'imei': imei,
      'marca': marca,
      'modelo': modelo,
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
      'sistemaOperativo': sistemaOperativo,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  DispositivoEntity copyWith({
    int? idDispositivo,
    int? idUsuario,
    String? imei,
    String? marca,
    String? modelo,
    DateTime? ultimoAcceso,
    String? sistemaOperativo,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
  }) {
    return DispositivoEntity(
      idDispositivo: idDispositivo ?? this.idDispositivo,
      idUsuario: idUsuario ?? this.idUsuario,
      imei: imei ?? this.imei,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      sistemaOperativo: sistemaOperativo ?? this.sistemaOperativo,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
    );
  }

  /// Verifica si tiene IMEI
  bool get tieneImei => imei != null && imei!.isNotEmpty;

  /// Verifica si tiene información completa del dispositivo
  bool get tieneInfoCompleta =>
      marca != null && modelo != null && sistemaOperativo != null;

  /// Obtiene el nombre del dispositivo formateado
  String get nombreDispositivo {
    if (marca != null && modelo != null) {
      return '$marca $modelo';
    } else if (marca != null) {
      return marca!;
    } else if (modelo != null) {
      return modelo!;
    } else {
      return 'Dispositivo desconocido';
    }
  }

  /// Obtiene la fecha del último acceso formateada
  String get ultimoAccesoFormateado {
    if (ultimoAcceso == null) return 'Nunca';
    return '${ultimoAcceso!.day.toString().padLeft(2, '0')}/${ultimoAcceso!.month.toString().padLeft(2, '0')}/${ultimoAcceso!.year}';
  }

  /// Verifica si el dispositivo está activo (último acceso en las últimas 24 horas)
  bool get isActivo {
    if (ultimoAcceso == null) return false;
    final ahora = DateTime.now();
    final diferencia = ahora.difference(ultimoAcceso!);
    return diferencia.inHours < 24;
  }

  /// Obtiene el tiempo desde el último acceso
  Duration? get tiempoDesdeUltimoAcceso {
    if (ultimoAcceso == null) return null;
    return DateTime.now().difference(ultimoAcceso!);
  }

  /// Obtiene el tiempo desde el último acceso formateado
  String get tiempoDesdeUltimoAccesoFormateado {
    final tiempo = tiempoDesdeUltimoAcceso;
    if (tiempo == null) return 'Nunca';

    if (tiempo.inDays > 0) {
      return '${tiempo.inDays} días';
    } else if (tiempo.inHours > 0) {
      return '${tiempo.inHours} horas';
    } else if (tiempo.inMinutes > 0) {
      return '${tiempo.inMinutes} minutos';
    } else {
      return 'Recién';
    }
  }

  /// Obtiene el sistema operativo formateado
  String get sistemaOperativoFormateado {
    if (sistemaOperativo == null) return 'Desconocido';
    return sistemaOperativo!.toUpperCase();
  }

  @override
  String toString() {
    return 'DispositivoEntity(idDispositivo: $idDispositivo, imei: $imei, nombre: $nombreDispositivo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DispositivoEntity &&
        other.idDispositivo == idDispositivo &&
        other.idUsuario == idUsuario &&
        other.imei == imei;
  }

  @override
  int get hashCode {
    return Object.hash(
      idDispositivo,
      idUsuario,
      imei,
    );
  }
}
