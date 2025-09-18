class FacturaEntity {
  final int? idFactura;
  final int? idVenta;
  final String? idCliente;
  final String? numeroFactura;
  final DateTime? fecha;
  final double? total;
  final String? comentario;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  FacturaEntity({
    this.idFactura,
    this.idVenta,
    this.idCliente,
    this.numeroFactura,
    this.fecha,
    this.total,
    this.comentario,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory FacturaEntity.fromJson(Map<String, dynamic> json) {
    return FacturaEntity(
      idFactura: json['IDFACTURA'],
      idVenta: json['IDVENTA'],
      idCliente: json['IDCLIENTE'],
      numeroFactura: json['NUMEROFACTURA'],
      fecha: json['FECHA'] != null ? DateTime.parse(json['FECHA']) : null,
      total: json['TOTAL']?.toDouble(),
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
    return {
      'IDFACTURA': idFactura,
      'IDVENTA': idVenta,
      'IDCLIENTE': idCliente,
      'NUMEROFACTURA': numeroFactura,
      'FECHA': fecha?.toIso8601String(),
      'TOTAL': total,
      'COMENTARIO': comentario,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOINGRESO': usuarioIngreso,
      'USERMODIFICACION': userModificacion,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idFactura': idFactura,
      'idVenta': idVenta,
      'idCliente': idCliente,
      'numeroFactura': numeroFactura,
      'fecha': fecha?.toIso8601String(),
      'total': total,
      'comentario': comentario,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioIngreso': usuarioIngreso,
      'userModificacion': userModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  FacturaEntity copyWith({
    int? idFactura,
    int? idVenta,
    String? idCliente,
    String? numeroFactura,
    DateTime? fecha,
    double? total,
    String? comentario,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioIngreso,
    String? userModificacion,
  }) {
    return FacturaEntity(
      idFactura: idFactura ?? this.idFactura,
      idVenta: idVenta ?? this.idVenta,
      idCliente: idCliente ?? this.idCliente,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      fecha: fecha ?? this.fecha,
      total: total ?? this.total,
      comentario: comentario ?? this.comentario,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioIngreso: usuarioIngreso ?? this.usuarioIngreso,
      userModificacion: userModificacion ?? this.userModificacion,
    );
  }

  /// Verifica si la factura tiene un número válido
  bool get tieneNumeroFactura =>
      numeroFactura != null && numeroFactura!.isNotEmpty;

  /// Obtiene la fecha formateada
  String get fechaFormateada {
    if (fecha == null) return 'Sin fecha';
    return '${fecha!.day.toString().padLeft(2, '0')}/${fecha!.month.toString().padLeft(2, '0')}/${fecha!.year}';
  }

  /// Obtiene el total formateado
  String get totalFormateado {
    if (total == null) return '\$0.00';
    return '\$${total!.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'FacturaEntity(idFactura: $idFactura, numeroFactura: $numeroFactura, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FacturaEntity &&
        other.idFactura == idFactura &&
        other.idVenta == idVenta &&
        other.numeroFactura == numeroFactura &&
        other.total == total;
  }

  @override
  int get hashCode {
    return Object.hash(
      idFactura,
      idVenta,
      numeroFactura,
      total,
    );
  }
}
