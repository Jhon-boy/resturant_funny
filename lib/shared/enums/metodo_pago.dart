// ignore_for_file: constant_identifier_names
// ENUMERADO DEDICADO PARA LOS MÉTODOS DE PAGO DISPONIBLES
enum MetodoPago {
  EFECTIVO("EFECTIVO", "Efectivo"),
  TARJETA("TARJETA", "Tarjeta"),
  TRANSFERENCIA("TRANSFERENCIA", "Transferencia"),
  CHEQUE("CHEQUE", "Cheque");

  final String value;
  final String label;

  const MetodoPago(this.value, this.label);

  /// Obtener lista de todos los métodos de pago para dropdown
  static List<MetodoPago> get all => MetodoPago.values;

  /// Verificar si requiere monto recibido (solo efectivo)
  bool get requiereMontoRecibido => this == MetodoPago.EFECTIVO;
}
