class MesaEntity {
  final int? idMesa;
  final int? idSucursal;
  final int? numero;
  final String? estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  MesaEntity({
    this.idMesa,
    this.idSucursal,
    this.numero,
    this.estado,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory MesaEntity.fromJson(Map<String, dynamic> json) {
    return MesaEntity(
      idMesa: json['IDMESA'],
      idSucursal: json['IDSUCURSAL'],
      numero: json['NUMERO'],
      estado: json['ESTADO'],
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
      'IDMESA': idMesa,
      'IDSUCURSAL': idSucursal,
      'NUMERO': numero,
      'ESTADO': estado,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idMesa': idMesa,
      'idSucursal': idSucursal,
      'numero': numero,
      'estado': estado,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  MesaEntity copyWith({
    int? idMesa,
    int? idSucursal,
    int? numero,
    String? estado,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
  }) {
    return MesaEntity(
      idMesa: idMesa ?? this.idMesa,
      idSucursal: idSucursal ?? this.idSucursal,
      numero: numero ?? this.numero,
      estado: estado ?? this.estado,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
    );
  }

  /// Verifica si la mesa está disponible
  bool get isDisponible =>
      estado?.toUpperCase() == 'DISPONIBLE' || estado == null;

  /// Verifica si la mesa está ocupada
  bool get isOcupada => estado?.toUpperCase() == 'OCUPADA';

  /// Verifica si la mesa está reservada
  bool get isReservada => estado?.toUpperCase() == 'RESERVADA';

  /// Verifica si la mesa está fuera de servicio
  bool get isFueraServicio => estado?.toUpperCase() == 'FUERA_SERVICIO';

  /// Obtiene el número de mesa formateado
  String get numeroFormateado {
    if (numero == null) return 'Sin número';
    return 'Mesa $numero';
  }

  /// Obtiene el estado con formato
  String get estadoFormateado {
    if (estado == null) return 'Disponible';
    return estado!.toUpperCase().replaceAll('_', ' ');
  }

  /// Obtiene el color del estado para la UI
  String get colorEstado {
    switch (estado?.toUpperCase()) {
      case 'DISPONIBLE':
        return 'verde';
      case 'OCUPADA':
        return 'rojo';
      case 'RESERVADA':
        return 'amarillo';
      case 'FUERA_SERVICIO':
        return 'gris';
      default:
        return 'verde';
    }
  }

  /// Obtiene el icono del estado para la UI
  String get iconoEstado {
    switch (estado?.toUpperCase()) {
      case 'DISPONIBLE':
        return 'check_circle';
      case 'OCUPADA':
        return 'person';
      case 'RESERVADA':
        return 'schedule';
      case 'FUERA_SERVICIO':
        return 'block';
      default:
        return 'check_circle';
    }
  }

  @override
  String toString() {
    return 'MesaEntity(idMesa: $idMesa, numero: $numero, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MesaEntity &&
        other.idMesa == idMesa &&
        other.idSucursal == idSucursal &&
        other.numero == numero &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return Object.hash(
      idMesa,
      idSucursal,
      numero,
      estado,
    );
  }
}
