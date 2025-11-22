import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/reportes/domain/models/producto_venta_stats.dart';

class EstadisticasProductosService {
  /// Calcula estadísticas de productos a partir de detalles de venta con productos
  static EstadisticasProductos calcularEstadisticas(
    List<Map<String, dynamic>> detallesConProductos,
  ) {
    if (detallesConProductos.isEmpty) {
      return EstadisticasProductos(
        topProductos: [],
        totalUnidadesVendidas: 0,
        totalIngresosProductos: 0.0,
        totalProductosDiferentes: 0,
      );
    }

    // Mapa para agrupar por producto
    final Map<int, Map<String, dynamic>> productosMap = {};

    for (final detalle in detallesConProductos) {
      final productoData = detalle['TPRODUCTO'] as Map<String, dynamic>?;
      if (productoData == null) continue;

      final idProducto = productoData['IDPRODUCTO'] as int;
      final cantidad = (detalle['CANTIDAD'] as num?)?.toInt() ?? 0;
      final subtotal = (detalle['SUBTOTAL'] as num?)?.toDouble() ?? 0.0;

      if (!productosMap.containsKey(idProducto)) {
        productosMap[idProducto] = {
          'producto': productoData,
          'total_cantidad': 0,
          'total_ingresos': 0.0,
          'numero_ventas': 0,
        };
      }

      productosMap[idProducto]!['total_cantidad'] =
          (productosMap[idProducto]!['total_cantidad'] as int) + cantidad;
      productosMap[idProducto]!['total_ingresos'] =
          (productosMap[idProducto]!['total_ingresos'] as double) + subtotal;
      productosMap[idProducto]!['numero_ventas'] =
          (productosMap[idProducto]!['numero_ventas'] as int) + 1;
    }

    // Convertir a lista de ProductoVentaStats
    final productosStats = productosMap.entries.map((entry) {
      final producto = ProductoEntity.fromJson(entry.value['producto']);
      return ProductoVentaStats.fromMap(entry.value, producto);
    }).toList();

    // Ordenar por cantidad vendida (descendente)
    productosStats.sort(
        (a, b) => b.totalCantidadVendida.compareTo(a.totalCantidadVendida));

    // Producto más vendido
    final productoMasVendido =
        productosStats.isNotEmpty ? productosStats.first : null;

    // Calcular estadísticas por categoría
    final Map<String, Map<String, dynamic>> categoriasMap = {};
    for (final stat in productosStats) {
      final categoria = stat.producto.categoria;
      if (!categoriasMap.containsKey(categoria)) {
        categoriasMap[categoria] = {
          'total_cantidad': 0,
          'total_ingresos': 0.0,
          'numero_productos': 0,
        };
      }
      categoriasMap[categoria]!['total_cantidad'] =
          (categoriasMap[categoria]!['total_cantidad'] as int) +
              stat.totalCantidadVendida;
      categoriasMap[categoria]!['total_ingresos'] =
          (categoriasMap[categoria]!['total_ingresos'] as double) +
              stat.totalIngresos;
      categoriasMap[categoria]!['numero_productos'] =
          (categoriasMap[categoria]!['numero_productos'] as int) + 1;
    }

    // Categoría más consumida
    CategoriaVentaStats? categoriaMasConsumida;
    if (categoriasMap.isNotEmpty) {
      final categoriaEntry = categoriasMap.entries.reduce((a, b) {
        return (a.value['total_cantidad'] as int) >
                (b.value['total_cantidad'] as int)
            ? a
            : b;
      });
      categoriaMasConsumida = CategoriaVentaStats(
        categoria: categoriaEntry.key,
        totalCantidadVendida: categoriaEntry.value['total_cantidad'] as int,
        totalIngresos: categoriaEntry.value['total_ingresos'] as double,
        numeroProductos: categoriaEntry.value['numero_productos'] as int,
      );
    }

    // Top 5 productos
    final topProductos = productosStats.take(5).toList();

    // Totales
    final totalUnidadesVendidas = productosStats
        .map((s) => s.totalCantidadVendida)
        .fold(0, (a, b) => a + b);
    final totalIngresosProductos =
        productosStats.map((s) => s.totalIngresos).fold(0.0, (a, b) => a + b);
    final totalProductosDiferentes = productosStats.length;

    return EstadisticasProductos(
      productoMasVendido: productoMasVendido,
      categoriaMasConsumida: categoriaMasConsumida,
      topProductos: topProductos,
      totalUnidadesVendidas: totalUnidadesVendidas,
      totalIngresosProductos: totalIngresosProductos,
      totalProductosDiferentes: totalProductosDiferentes,
    );
  }
}
