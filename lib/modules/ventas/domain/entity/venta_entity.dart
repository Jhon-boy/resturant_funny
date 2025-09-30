class VentaEntity {
  final int? idVenta;
  final int idMesa;
  final String cliente;
  final int idEmpleado;
  final String? tipoVenta;
  final DateTime? fecha;
  final double? subtotal;
  final double? delivery;
  final double? total;
  final String? estado;
  final bool? conFactura;
  final String? comentario;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  VentaEntity({
    this.idVenta,
    required this.idMesa,
    required this.cliente,
    required this.idEmpleado,
    this.tipoVenta,
    this.fecha,
    this.subtotal,
    this.delivery,
    this.total,
    this.estado,
    this.conFactura,
    this.comentario,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory VentaEntity.fromJson(Map<String, dynamic> json) {
    return VentaEntity(
      idVenta: json['IDVENTA'],
      idMesa: json['IDMESA'] ?? 0,
      cliente: json['CLIENTE'] ?? '',
      idEmpleado: json['IDEMPLEADO'] ?? 0,
      tipoVenta: json['TIPO_VENTA'],
      fecha: json['FECHA'] != null ? DateTime.parse(json['FECHA']) : null,
      subtotal: json['SUBTOTAL']?.toDouble(),
      delivery: json['DELIVERY']?.toDouble(),
      total: json['TOTAL']?.toDouble(),
      estado: json['ESTADO'],
      conFactura: json['CONFACTURA'],
      comentario: json['COMENTARIO'],
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
    final data = <String, dynamic>{
      'IDMESA': idMesa,
      'CLIENTE': cliente,
      'IDEMPLEADO': idEmpleado,
      'TIPO_VENTA': tipoVenta,
      'FECHA': fecha?.toIso8601String(),
      'SUBTOTAL': subtotal,
      'DELIVERY': delivery,
      'TOTAL': total,
      'ESTADO': estado,
      'CONFACTURA': conFactura,
      'COMENTARIO': comentario,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
    };
 
    if (idVenta != null) {
      data['IDVENTA'] = idVenta;
    }

    return data;
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idVenta': idVenta,
      'idMesa': idMesa,
      'cliente': cliente,
      'idEmpleado': idEmpleado,
      'tipoVenta': tipoVenta,
      'fecha': fecha?.toIso8601String(),
      'subtotal': subtotal,
      'delivery': delivery,
      'total': total,
      'estado': estado,
      'conFactura': conFactura,
      'comentario': comentario,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  VentaEntity copyWith({
    int? idVenta,
    int? idMesa,
    String? cliente,
    int? idEmpleado,
    String? tipoVenta,
    DateTime? fecha,
    double? subtotal,
    double? delivery,
    double? total,
    String? estado,
    bool? conFactura,
    String? comentario,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
  }) {
    return VentaEntity(
      idVenta: idVenta ?? this.idVenta,
      idMesa: idMesa ?? this.idMesa,
      cliente: cliente ?? this.cliente,
      idEmpleado: idEmpleado ?? this.idEmpleado,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      fecha: fecha ?? this.fecha,
      subtotal: subtotal ?? this.subtotal,
      delivery: delivery ?? this.delivery,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      conFactura: conFactura ?? this.conFactura,
      comentario: comentario ?? this.comentario,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
    );
  }

  /// Verifica si la venta está pendiente
  bool get isPendiente => estado?.toUpperCase() == 'PENDIENTE';

  /// Verifica si la venta está completada
  bool get isCompletada => estado?.toUpperCase() == 'COMPLETADA';

  /// Verifica si la venta está cancelada
  bool get isCancelada => estado?.toUpperCase() == 'CANCELADA';

  /// Verifica si la venta está en proceso
  bool get isEnProceso => estado?.toUpperCase() == 'EN_PROCESO';

  /// Verifica si es venta con delivery
  bool get esDelivery => tipoVenta?.toUpperCase() == 'DELIVERY';

  /// Verifica si es venta en local
  bool get esLocal => tipoVenta?.toUpperCase() == 'LOCAL';

  /// Verifica si es venta para llevar
  bool get esParaLlevar => tipoVenta?.toUpperCase() == 'PARA_LLEVAR';

  /// Obtiene el subtotal formateado
  String get subtotalFormateado {
    if (subtotal == null) return '\$0.00';
    return '\$${subtotal!.toStringAsFixed(2)}';
  }

  /// Obtiene el delivery formateado
  String get deliveryFormateado {
    if (delivery == null) return '\$0.00';
    return '\$${delivery!.toStringAsFixed(2)}';
  }

  /// Obtiene el total formateado
  String get totalFormateado {
    if (total == null) return '\$0.00';
    return '\$${total!.toStringAsFixed(2)}';
  }

  /// Obtiene la fecha formateada
  String get fechaFormateada {
    if (fecha == null) return 'Sin fecha';
    return '${fecha!.day.toString().padLeft(2, '0')}/${fecha!.month.toString().padLeft(2, '0')}/${fecha!.year}';
  }

  /// Obtiene el estado con formato
  String get estadoFormateado {
    if (estado == null) return 'Sin estado';
    return estado!.toUpperCase().replaceAll('_', ' ');
  }

  /// Obtiene el tipo de venta con formato
  String get tipoVentaFormateado {
    if (tipoVenta == null) return 'Sin tipo';
    return tipoVenta!.toUpperCase().replaceAll('_', ' ');
  }

  /// Obtiene el color del estado para la UI
  String get colorEstado {
    switch (estado?.toUpperCase()) {
      case 'PENDIENTE':
        return 'amarillo';
      case 'EN_PROCESO':
        return 'azul';
      case 'COMPLETADA':
        return 'verde';
      case 'CANCELADA':
        return 'rojo';
      default:
        return 'gris';
    }
  }

  /// Obtiene el icono del estado para la UI
  String get iconoEstado {
    switch (estado?.toUpperCase()) {
      case 'PENDIENTE':
        return 'schedule';
      case 'EN_PROCESO':
        return 'play_circle';
      case 'COMPLETADA':
        return 'check_circle';
      case 'CANCELADA':
        return 'cancel';
      default:
        return 'help';
    }
  }

  /// Calcula el total con delivery
  double get totalConDelivery {
    final subtotalValue = subtotal ?? 0.0;
    final deliveryValue = delivery ?? 0.0;
    return subtotalValue + deliveryValue;
  }

  /// Obtiene el total con delivery formateado
  String get totalConDeliveryFormateado {
    return '\$${totalConDelivery.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'VentaEntity(idVenta: $idVenta, cliente: $cliente, total: $total, estado: $estado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VentaEntity &&
        other.idVenta == idVenta &&
        other.idMesa == idMesa &&
        other.cliente == cliente &&
        other.total == total;
  }

  @override
  int get hashCode {
    return Object.hash(
      idVenta,
      idMesa,
      cliente,
      total,
    );
  }
}
