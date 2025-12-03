import 'package:flutter/material.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/domain/models/producto_mas_vendido_model.dart';

/// Servicio de dominio para calcular productos más vendidos
/// a partir de las ventas y sus detalles en Supabase.
class ProductosMasVendidosService {
  final VentasRemoteDataSource remote;

  const ProductosMasVendidosService({required this.remote});

  /// Obtiene los productos más vendidos para un empleado
  /// entre [fechaDesde] y [fechaHasta].
  Future<List<ProductoMasVendidoModel>> getProductosMasVendidosEmpleado({
    required int idEmpleado,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) async {
    try {
      final rows = await remote.getVentasConDetalles(
        idEmpleado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );

      final Map<int, _ProductoAcumulado> acumulado = {};

      for (final v in rows) {
        final detalles = v['TDETALLEVENTA'];
        if (detalles is! List) continue;

        for (final detRaw in detalles) {
          if (detRaw is! Map) continue;
          final det = Map<String, dynamic>.from(detRaw);

          final idProd = (det['IDPRODUCTO'] as num?)?.toInt();
          if (idProd == null) continue;

          final prod = det['TPRODUCTO'] as Map?;
          final prodMap = prod?.cast<String, dynamic>();
          final nombre = (prodMap?['NOMBRE'] ?? '').toString();

          final cantidad = (det['CANTIDAD'] as num?)?.toInt() ?? 0;
          // Si existen campos de precio/subtotal, los usamos. Si no, al menos contamos unidades.
          final subtotal = (det['SUBTOTAL'] as num?)?.toDouble();
          final precioUnit = (det['PRECIO_UNITARIO'] as num?)?.toDouble();
          final ingreso = subtotal ?? ((precioUnit ?? 0.0) * cantidad);

          final actual = acumulado[idProd];
          if (actual == null) {
            acumulado[idProd] = _ProductoAcumulado(
              idProducto: idProd,
              nombreProducto: nombre,
              cantidadVendida: cantidad,
              ingresosTotales: ingreso,
            );
          } else {
            actual.cantidadVendida += cantidad;
            actual.ingresosTotales += ingreso;
          }
        }
      }

      final lista = acumulado.values
          .map(
            (p) => ProductoMasVendidoModel(
              idProducto: p.idProducto,
              nombreProducto: p.nombreProducto,
              cantidadVendida: p.cantidadVendida,
              ingresosTotales: p.ingresosTotales,
            ),
          )
          .toList();

      lista.sort((a, b) => b.cantidadVendida.compareTo(a.cantidadVendida));
      return lista;
    } catch (e) {
      debugPrint('Error en getProductosMasVendidosEmpleado: $e');
      return [];
    }
  }
}

class _ProductoAcumulado {
  final int idProducto;
  final String nombreProducto;
  int cantidadVendida;
  double ingresosTotales;

  _ProductoAcumulado({
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidadVendida,
    required this.ingresosTotales,
  });
}
