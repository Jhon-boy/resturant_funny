class PlanillaEntity {
  final int? idPlanilla;
  final int idSucursal;
  final String? identificacion;
  final String? periodo;
  final double? sueldoBase;
  final double? comision;
  final double? bonificacion;
  final double? descuento;
  final double? totalPagar;
  final DateTime? fechaPago;
  final String estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  PlanillaEntity({
    this.idPlanilla,
    required this.idSucursal,
    this.identificacion,
    this.periodo,
    this.sueldoBase,
    this.comision,
    this.bonificacion,
    this.descuento,
    this.totalPagar,
    this.fechaPago,
    required this.estado,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory PlanillaEntity.fromJson(Map<String, dynamic> json) {
    return PlanillaEntity(
      idPlanilla: json['IDPLANILLA'],
      idSucursal: json['IDSUCURSAL'] ?? 0,
      identificacion: json['IDENTIFICACION'],
      periodo: json['PERIODO'],
      sueldoBase: json['SUELDO_BASE']?.toDouble(),
      comision: json['COMISION']?.toDouble(),
      bonificacion: json['BONIFICACION']?.toDouble(),
      descuento: json['DESCUENTO']?.toDouble(),
      totalPagar: json['TOTAL_PAGAR']?.toDouble(),
      fechaPago: json['FECHA_PAGO'] != null
          ? DateTime.parse(json['FECHA_PAGO'])
          : null,
      estado: json['ESTADO'] ?? 'PENDIENTE',
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
      'IDPLANILLA': idPlanilla,
      'IDSUCURSAL': idSucursal,
      'IDENTIFICACION': identificacion,
      'PERIODO': periodo,
      'SUELDO_BASE': sueldoBase,
      'COMISION': comision,
      'BONIFICACION': bonificacion,
      'DESCUENTO': descuento,
      'TOTAL_PAGAR': totalPagar,
      'FECHA_PAGO': fechaPago?.toIso8601String(),
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
      'idPlanilla': idPlanilla,
      'idSucursal': idSucursal,
      'identificacion': identificacion,
      'periodo': periodo,
      'sueldoBase': sueldoBase,
      'comision': comision,
      'bonificacion': bonificacion,
      'descuento': descuento,
      'totalPagar': totalPagar,
      'fechaPago': fechaPago?.toIso8601String(),
      'estado': estado,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  PlanillaEntity copyWith({
    int? idPlanilla,
    int? idSucursal,
    String? identificacion,
    String? periodo,
    double? sueldoBase,
    double? comision,
    double? bonificacion,
    double? descuento,
    double? totalPagar,
    DateTime? fechaPago,
    String? estado,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
  }) {
    return PlanillaEntity(
      idPlanilla: idPlanilla ?? this.idPlanilla,
      idSucursal: idSucursal ?? this.idSucursal,
      identificacion: identificacion ?? this.identificacion,
      periodo: periodo ?? this.periodo,
      sueldoBase: sueldoBase ?? this.sueldoBase,
      comision: comision ?? this.comision,
      bonificacion: bonificacion ?? this.bonificacion,
      descuento: descuento ?? this.descuento,
      totalPagar: totalPagar ?? this.totalPagar,
      fechaPago: fechaPago ?? this.fechaPago,
      estado: estado ?? this.estado,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
    );
  }

  /// Verifica si la planilla está pendiente
  bool get isPendiente => estado.toUpperCase() == 'PENDIENTE';

  /// Verifica si la planilla está pagada
  bool get isPagada => estado.toUpperCase() == 'PAGADA';

  /// Verifica si la planilla está cancelada
  bool get isCancelada => estado.toUpperCase() == 'CANCELADA';

  /// Verifica si la planilla está en proceso
  bool get isEnProceso => estado.toUpperCase() == 'EN_PROCESO';

  /// Calcula el total a pagar automáticamente
  double get totalCalculado {
    final sueldo = sueldoBase ?? 0.0;
    final comisionValue = comision ?? 0.0;
    final bonificacionValue = bonificacion ?? 0.0;
    final descuentoValue = descuento ?? 0.0;

    return sueldo + comisionValue + bonificacionValue - descuentoValue;
  }

  /// Obtiene el sueldo base formateado
  String get sueldoBaseFormateado {
    if (sueldoBase == null) return '\$0.00';
    return '\$${sueldoBase!.toStringAsFixed(2)}';
  }

  /// Obtiene la comisión formateada
  String get comisionFormateada {
    if (comision == null) return '\$0.00';
    return '\$${comision!.toStringAsFixed(2)}';
  }

  /// Obtiene la bonificación formateada
  String get bonificacionFormateada {
    if (bonificacion == null) return '\$0.00';
    return '\$${bonificacion!.toStringAsFixed(2)}';
  }

  /// Obtiene el descuento formateado
  String get descuentoFormateado {
    if (descuento == null) return '\$0.00';
    return '\$${descuento!.toStringAsFixed(2)}';
  }

  /// Obtiene el total a pagar formateado
  String get totalPagarFormateado {
    final total = totalPagar ?? totalCalculado;
    return '\$${total.toStringAsFixed(2)}';
  }

  /// Obtiene la fecha de pago formateada
  String get fechaPagoFormateada {
    if (fechaPago == null) return 'Sin pagar';
    return '${fechaPago!.day.toString().padLeft(2, '0')}/${fechaPago!.month.toString().padLeft(2, '0')}/${fechaPago!.year}';
  }

  /// Obtiene el estado con formato
  String get estadoFormateado {
    return estado.toUpperCase().replaceAll('_', ' ');
  }

  /// Obtiene el color del estado para la UI
  String get colorEstado {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return 'amarillo';
      case 'EN_PROCESO':
        return 'azul';
      case 'PAGADA':
        return 'verde';
      case 'CANCELADA':
        return 'rojo';
      default:
        return 'gris';
    }
  }

  /// Obtiene el icono del estado para la UI
  String get iconoEstado {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE':
        return 'schedule';
      case 'EN_PROCESO':
        return 'play_circle';
      case 'PAGADA':
        return 'check_circle';
      case 'CANCELADA':
        return 'cancel';
      default:
        return 'help';
    }
  }

  /// Verifica si tiene fecha de pago
  bool get tieneFechaPago => fechaPago != null;

  /// Verifica si el total está calculado correctamente
  bool get totalCorrecto => (totalPagar ?? 0.0) == totalCalculado;

  @override
  String toString() {
    return 'PlanillaEntity(idPlanilla: $idPlanilla, periodo: $periodo, total: $totalPagarFormateado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanillaEntity &&
        other.idPlanilla == idPlanilla &&
        other.idSucursal == idSucursal &&
        other.identificacion == identificacion &&
        other.periodo == periodo;
  }

  @override
  int get hashCode {
    return Object.hash(
      idPlanilla,
      idSucursal,
      identificacion,
      periodo,
    );
  }
}
