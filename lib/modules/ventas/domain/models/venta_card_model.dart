class VentaCardModel {
  final int idVenta;
  final int idMesa;
  final String nombreCliente;
  final String? identificacionCliente;
  final String? nombreProducto;
  final int? cantidadProducto;
  final double total;
  final DateTime? fecha;
  final String? estado;

  const VentaCardModel({
    required this.idVenta,
    required this.idMesa,
    required this.nombreCliente,
    required this.total,
    this.identificacionCliente,
    this.nombreProducto,
    this.cantidadProducto,
    this.fecha,
    this.estado,
  });
}
