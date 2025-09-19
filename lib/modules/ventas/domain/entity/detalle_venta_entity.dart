class DetalleVentaEntity {
  final int? idDetalle;
  final int idVenta;
  final int idProducto;
  final int cantidad;
  final String? metodoPago;
  final double precioUnitario;
  final double subtotal;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioIngreso;
  final String? userModificacion;

  DetalleVentaEntity({
    this.idDetalle,
    required this.idVenta,
    required this.idProducto,
    required this.cantidad,
    this.metodoPago,
    required this.precioUnitario,
    required this.subtotal,
    this.fCreacion,
    this.fModificacion,
    this.usuarioIngreso,
    this.userModificacion,
  });

  factory DetalleVentaEntity.fromJson(Map<String, dynamic> json) =>
      DetalleVentaEntity(
        idDetalle: json['IDDETALLE'] as int?,
        idVenta: json['IDVENTA'] as int,
        idProducto: json['IDPRODUCTO'] as int,
        cantidad: json['CANTIDAD'] as int,
        metodoPago: json['METODOPAGO'] as String?,
        precioUnitario: (json['PRECIO_UNITARIO'] as num).toDouble(),
        subtotal: (json['SUBTOTAL'] as num).toDouble(),
        fCreacion: json['FCREACION'] != null
            ? DateTime.parse(json['FCREACION'])
            : null,
        fModificacion: json['FMODIFICACION'] != null
            ? DateTime.parse(json['FMODIFICACION'])
            : null,
        usuarioIngreso: json['USUARIOINGRESO'] as String?,
        userModificacion: json['USERMODIFICACION'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'IDDETALLE': idDetalle,
        'IDVENTA': idVenta,
        'IDPRODUCTO': idProducto,
        'CANTIDAD': cantidad,
        'METODOPAGO': metodoPago,
        'PRECIO_UNITARIO': precioUnitario,
        'SUBTOTAL': subtotal,
        'FCREACION': fCreacion?.toIso8601String(),
        'FMODIFICACION': fModificacion?.toIso8601String(),
        'USUARIOINGRESO': usuarioIngreso,
        'USERMODIFICACION': userModificacion,
      };
}
