class ProductoMasVendidoModel {
  final int idProducto;
  final String nombreProducto;
  final int cantidadVendida;
  final double ingresosTotales;

  const ProductoMasVendidoModel({
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidadVendida,
    required this.ingresosTotales,
  });
}
