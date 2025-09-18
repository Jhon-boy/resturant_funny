class IngresoEgresoEntity {
  final int? idMovimiento;
  final int idSucursal;
  final String? tipo;
  final String? categoria;
  final String? descripcion;
  final double? monto;
  final DateTime? fecha;
  final String? referencia;
  final String? estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  IngresoEgresoEntity({
    this.idMovimiento,
    required this.idSucursal,
    this.tipo,
    this.categoria,
    this.descripcion,
    this.monto,
    this.fecha,
    this.referencia,
    this.estado,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory IngresoEgresoEntity.fromJson(Map<String, dynamic> json) {
    return IngresoEgresoEntity(
      idMovimiento: json['IDMOVIMIENTO'],
      idSucursal: json['IDSUCURSAL'] ?? 0,
      tipo: json['TIPO'],
      categoria: json['CATEGORIA'],
      descripcion: json['DESCRIPCION'],
      monto: json['MONTO']?.toDouble(),
      fecha: json['FECHA'] != null ? DateTime.parse(json['FECHA']) : null,
      referencia: json['REFERENCIA'],
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
      'IDMOVIMIENTO': idMovimiento,
      'IDSUCURSAL': idSucursal,
      'TIPO': tipo,
      'CATEGORIA': categoria,
      'DESCRIPCION': descripcion,
      'MONTO': monto,
      'FECHA': fecha?.toIso8601String(),
      'REFERENCIA': referencia,
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
      'idMovimiento': idMovimiento,
      'idSucursal': idSucursal,
      'tipo': tipo,
      'categoria': categoria,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha?.toIso8601String(),
      'referencia': referencia,
      'estado': estado,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  IngresoEgresoEntity copyWith({
    int? idMovimiento,
    int? idSucursal,
    String? tipo,
    String? categoria,
    String? descripcion,
    double? monto,
    DateTime? fecha,
    String? referencia,
    String? estado,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
  }) {
    return IngresoEgresoEntity(
      idMovimiento: idMovimiento ?? this.idMovimiento,
      idSucursal: idSucursal ?? this.idSucursal,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      referencia: referencia ?? this.referencia,
      estado: estado ?? this.estado,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
    );
  }

  /// Verifica si es un ingreso
  bool get esIngreso => tipo?.toUpperCase() == 'INGRESO';

  /// Verifica si es un egreso
  bool get esEgreso => tipo?.toUpperCase() == 'EGRESO';

  /// Obtiene el monto formateado
  String get montoFormateado {
    if (monto == null) return '\$0.00';
    return '\$${monto!.toStringAsFixed(2)}';
  }

  /// Obtiene la fecha formateada
  String get fechaFormateada {
    if (fecha == null) return 'Sin fecha';
    return '${fecha!.day.toString().padLeft(2, '0')}/${fecha!.month.toString().padLeft(2, '0')}/${fecha!.year}';
  }

  /// Obtiene el tipo con formato
  String get tipoFormateado {
    if (tipo == null) return 'Sin tipo';
    return tipo!.toUpperCase();
  }

  /// Obtiene el estado con formato
  String get estadoFormateado {
    if (estado == null) return 'Sin estado';
    return estado!.toUpperCase();
  }

  @override
  String toString() {
    return 'IngresoEgresoEntity(idMovimiento: $idMovimiento, tipo: $tipo, monto: $monto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IngresoEgresoEntity &&
        other.idMovimiento == idMovimiento &&
        other.idSucursal == idSucursal &&
        other.tipo == tipo &&
        other.monto == monto;
  }

  @override
  int get hashCode {
    return Object.hash(
      idMovimiento,
      idSucursal,
      tipo,
      monto,
    );
  }
}
