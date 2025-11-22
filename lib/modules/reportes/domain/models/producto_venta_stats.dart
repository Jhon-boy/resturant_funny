import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';

/// Modelo para representar estadísticas de un producto vendido
class ProductoVentaStats {
  final ProductoEntity producto;
  final int totalCantidadVendida;
  final double totalIngresos;
  final int numeroVentas; // Número de veces que se vendió

  ProductoVentaStats({
    required this.producto,
    required this.totalCantidadVendida,
    required this.totalIngresos,
    required this.numeroVentas,
  });

  /// Crea un ProductoVentaStats desde un mapa con datos agregados
  factory ProductoVentaStats.fromMap(
    Map<String, dynamic> map,
    ProductoEntity producto,
  ) {
    return ProductoVentaStats(
      producto: producto,
      totalCantidadVendida: (map['total_cantidad'] as num?)?.toInt() ?? 0,
      totalIngresos: (map['total_ingresos'] as num?)?.toDouble() ?? 0.0,
      numeroVentas: (map['numero_ventas'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Modelo para estadísticas por categoría
class CategoriaVentaStats {
  final String categoria;
  final int totalCantidadVendida;
  final double totalIngresos;
  final int numeroProductos; // Número de productos diferentes vendidos

  CategoriaVentaStats({
    required this.categoria,
    required this.totalCantidadVendida,
    required this.totalIngresos,
    required this.numeroProductos,
  });
}

/// Modelo para estadísticas generales de productos
class EstadisticasProductos {
  final ProductoVentaStats? productoMasVendido;
  final CategoriaVentaStats? categoriaMasConsumida;
  final List<ProductoVentaStats> topProductos;
  final int totalUnidadesVendidas;
  final double totalIngresosProductos;
  final int totalProductosDiferentes;

  EstadisticasProductos({
    this.productoMasVendido,
    this.categoriaMasConsumida,
    required this.topProductos,
    required this.totalUnidadesVendidas,
    required this.totalIngresosProductos,
    required this.totalProductosDiferentes,
  });
}
