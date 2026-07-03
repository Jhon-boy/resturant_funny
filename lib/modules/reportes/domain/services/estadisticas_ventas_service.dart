import 'package:resturant_funny/modules/ventas/domain/entity/factura_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';
import 'package:resturant_funny/modules/reportes/domain/models/estadisticas_ventas_model.dart';

class EstadisticasVentasService {
  /// Calcula estadísticas completas de ventas
  static EstadisticasVentasCompletas calcularEstadisticas({
    required List<VentaEntity> ventas,
    required List<FacturaEntity> facturas,
    required Map<int, String> nombresEmpleados,
    required Map<String, String> nombresClientes,
    required Map<int, String> nombresMesas,
    required Map<int, String> nombresProductos,
    required Map<int, String> nombresPorciones,
    required Map<int, int> productosVendidos,
    required Map<int, int> porcionesVendidas,
    required Map<int, double> montosPorEmpleado,
    required Map<String, double> montosPorCliente,
    required Map<int, double> montosPorMesa,
    required DateTime fechaInicio,
    required DateTime fechaHasta,
    required List<Map<String, dynamic>> detallesConProductos,
  }) {
    // Estadísticas básicas
    final totalVentas = ventas.length;
    final montoTotalVendido = ventas
        .where((v) => v.total != null)
        .map((v) => v.total!)
        .fold(0.0, (a, b) => a + b);
    final promedioVenta =
        totalVentas > 0 ? montoTotalVendido / totalVentas : 0.0;

    // Facturas: solo contar ventas con CONFACTURA = true
    final ventasConFactura = ventas.where((v) => v.conFactura == true).toList();
    final totalFacturas = ventasConFactura.length;
    final montoTotalFacturado = ventasConFactura
        .where((v) => v.total != null)
        .map((v) => v.total!)
        .fold(0.0, (a, b) => a + b);

    // Ventas por día
    final ventasPorDia = <VentaDiaStats>[];
    final dias = _generarDias(fechaInicio, fechaHasta);

    for (final dia in dias) {
      final ventasDia = ventas.where((v) {
        if (v.fecha == null) return false;
        final fechaVenta = v.fecha!;
        return fechaVenta.year == dia.year &&
            fechaVenta.month == dia.month &&
            fechaVenta.day == dia.day;
      }).toList();

      // Facturas del día: contar ventas con CONFACTURA = true
      final facturasDia = ventasDia.where((v) => v.conFactura == true).toList();

      final montoDia = ventasDia
          .where((v) => v.total != null)
          .map((v) => v.total!)
          .fold(0.0, (a, b) => a + b);

      final nombreDia = _obtenerNombreDia(dia, fechaInicio);

      ventasPorDia.add(VentaDiaStats(
        dia: nombreDia,
        fecha: dia,
        numeroVentas: ventasDia.length,
        montoTotal: montoDia,
        numeroFacturas: facturasDia.length,
      ));
    }

    final promedioPorDia = ventasPorDia.isNotEmpty
        ? ventasPorDia.map((v) => v.montoTotal).fold(0.0, (a, b) => a + b) /
            ventasPorDia.length
        : 0.0;

    // Ventas por empleado
    final ventasPorEmpleado = <VentaEmpleadoStats>[];
    final empleadosUnicos = <int>{};
    for (final venta in ventas) {
      empleadosUnicos.add(venta.idEmpleado);
    }

    for (final idEmpleado in empleadosUnicos) {
      final ventasEmpleado =
          ventas.where((v) => v.idEmpleado == idEmpleado).toList();
      final montoEmpleado = montosPorEmpleado[idEmpleado] ?? 0.0;

      ventasPorEmpleado.add(VentaEmpleadoStats(
        idEmpleado: idEmpleado,
        nombreEmpleado: nombresEmpleados[idEmpleado] ?? 'Empleado #$idEmpleado',
        totalVentas: ventasEmpleado.length,
        montoTotal: montoEmpleado,
      ));
    }
    ventasPorEmpleado.sort((a, b) => b.totalVentas.compareTo(a.totalVentas));
    final empleadoTop =
        ventasPorEmpleado.isNotEmpty ? ventasPorEmpleado.first : null;

    // Ventas por cliente
    final ventasPorCliente = <VentaClienteStats>[];
    final clientesUnicos = <String>{};
    for (final venta in ventas) {
      clientesUnicos.add(venta.cliente);
    }

    for (final clienteId in clientesUnicos) {
      final ventasCliente =
          ventas.where((v) => v.cliente == clienteId).toList();
      final montoCliente = montosPorCliente[clienteId] ?? 0.0;

      ventasPorCliente.add(VentaClienteStats(
        identificacionCliente: clienteId,
        nombreCliente: nombresClientes[clienteId] ?? 'Cliente #$clienteId',
        totalCompras: ventasCliente.length,
        montoTotal: montoCliente,
      ));
    }
    ventasPorCliente.sort((a, b) => b.totalCompras.compareTo(a.totalCompras));
    final clienteTop =
        ventasPorCliente.isNotEmpty ? ventasPorCliente.first : null;

    // Ventas por mesa
    final ventasPorMesa = <MesaStats>[];
    final mesasUnicas = <int>{};
    for (final venta in ventas) {
      mesasUnicas.add(venta.idMesa);
    }

    for (final idMesa in mesasUnicas) {
      final ventasMesa = ventas.where((v) => v.idMesa == idMesa).toList();
      final montoMesa = montosPorMesa[idMesa] ?? 0.0;

      ventasPorMesa.add(MesaStats(
        idMesa: idMesa,
        nombreMesa: nombresMesas[idMesa] ?? 'Mesa #$idMesa',
        totalVentas: ventasMesa.length,
        montoTotal: montoMesa,
      ));
    }
    ventasPorMesa.sort((a, b) => b.totalVentas.compareTo(a.totalVentas));
    final mesaTop = ventasPorMesa.isNotEmpty ? ventasPorMesa.first : null;

    // Ventas por tipo
    final ventasPorTipo = <String, int>{};
    for (final venta in ventas) {
      final tipo = venta.tipoVenta ?? 'Sin tipo';
      ventasPorTipo[tipo] = (ventasPorTipo[tipo] ?? 0) + 1;
    }

    // Porciones vendidas
    final porcionesList = <PorcionStats>[];
    for (final entry in porcionesVendidas.entries) {
      porcionesList.add(PorcionStats(
        idProducto: entry.key,
        nombreProducto: nombresPorciones[entry.key] ?? 'Porción #${entry.key}',
        cantidadVendida: entry.value,
        montoTotal: 0.0, // Se puede calcular si se tiene el precio
      ));
    }
    porcionesList
        .sort((a, b) => b.cantidadVendida.compareTo(a.cantidadVendida));
    final porcionTop = porcionesList.isNotEmpty ? porcionesList.first : null;

    // Productos con cantidad de ventas (cuántas veces se vendió cada producto)
    final productosConVentasMap = <int, ProductoVentaCount>{};
    final productosPorVenta = <int, Set<int>>{}; // idVenta -> Set<idProducto>

    for (final detalleJson in detallesConProductos) {
      final productoJson = detalleJson['TPRODUCTO'] as Map<String, dynamic>?;
      if (productoJson == null) continue;

      final idProducto = productoJson['IDPRODUCTO'] as int?;
      final idVenta = detalleJson['IDVENTA'] as int?;
      final cantidad = detalleJson['CANTIDAD'] as int? ?? 0;
      final subtotal = (detalleJson['SUBTOTAL'] as num?)?.toDouble() ?? 0.0;

      if (idProducto == null || idVenta == null) continue;

      // Agregar producto a la venta
      productosPorVenta.putIfAbsent(idVenta, () => <int>{}).add(idProducto);

      // Actualizar estadísticas del producto
      if (productosConVentasMap.containsKey(idProducto)) {
        final existing = productosConVentasMap[idProducto]!;
        productosConVentasMap[idProducto] = ProductoVentaCount(
          idProducto: idProducto,
          nombreProducto: existing.nombreProducto,
          cantidadVentas: existing.cantidadVentas,
          cantidadUnidades: existing.cantidadUnidades + cantidad,
          montoTotal: existing.montoTotal + subtotal,
        );
      } else {
        productosConVentasMap[idProducto] = ProductoVentaCount(
          idProducto: idProducto,
          nombreProducto:
              nombresProductos[idProducto] ?? 'Producto #$idProducto',
          cantidadVentas: 0, // Se calculará después
          cantidadUnidades: cantidad,
          montoTotal: subtotal,
        );
      }
    }

    // Calcular cantidad de ventas por producto
    for (final ventaProductos in productosPorVenta.values) {
      for (final idProducto in ventaProductos) {
        if (productosConVentasMap.containsKey(idProducto)) {
          final existing = productosConVentasMap[idProducto]!;
          productosConVentasMap[idProducto] = ProductoVentaCount(
            idProducto: existing.idProducto,
            nombreProducto: existing.nombreProducto,
            cantidadVentas: existing.cantidadVentas + 1,
            cantidadUnidades: existing.cantidadUnidades,
            montoTotal: existing.montoTotal,
          );
        }
      }
    }

    final productosConVentas = productosConVentasMap.values.toList()
      ..sort((a, b) => b.cantidadVentas.compareTo(a.cantidadVentas));

    // Estadísticas adicionales
    final ticketPromedio = promedioVenta; // Ya calculado
    final ventasConDelivery =
        ventas.where((v) => (v.delivery ?? 0.0) > 0.0).length;
    final montoTotalDelivery = ventas
        .where((v) => v.delivery != null)
        .map((v) => v.delivery!)
        .fold(0.0, (a, b) => a + b);

    // Desglose por método de pago (usando detallesConProductos que incluye METODOPAGO)
    final Map<String, ({int count, double monto})> mpMap = {};
    for (final d in detallesConProductos) {
      final mp = (d['METODOPAGO'] as String?) ?? 'SIN_ESPECIFICAR';
      final sub = (d['SUBTOTAL'] as num?)?.toDouble() ?? 0.0;
      final prev = mpMap[mp];
      mpMap[mp] = prev == null
          ? (count: 1, monto: sub)
          : (count: prev.count + 1, monto: prev.monto + sub);
    }
    final ventasPorMetodoPago = mpMap.entries
        .map((e) => MetodoPagoStats(
              metodoPago: e.key,
              totalTransacciones: e.value.count,
              montoTotal: e.value.monto,
            ))
        .toList()
      ..sort((a, b) => b.montoTotal.compareTo(a.montoTotal));

    return EstadisticasVentasCompletas(
      totalVentas: totalVentas,
      montoTotalVendido: montoTotalVendido,
      promedioVenta: promedioVenta,
      totalFacturas: totalFacturas,
      montoTotalFacturado: montoTotalFacturado,
      ventasPorDia: ventasPorDia,
      promedioPorDia: promedioPorDia,
      ventasPorEmpleado: ventasPorEmpleado,
      empleadoTop: empleadoTop,
      ventasPorCliente: ventasPorCliente,
      clienteTop: clienteTop,
      ventasPorMesa: ventasPorMesa,
      mesaTop: mesaTop,
      ventasPorTipo: ventasPorTipo,
      productosVendidos: productosVendidos,
      nombresProductos: nombresProductos,
      productosConVentas: productosConVentas,
      porcionesVendidas: porcionesList,
      porcionTop: porcionTop,
      ticketPromedio: ticketPromedio,
      ventasConDelivery: ventasConDelivery,
      montoTotalDelivery: montoTotalDelivery,
      ventasPorMetodoPago: ventasPorMetodoPago,
    );
  }

  static List<DateTime> _generarDias(DateTime inicio, DateTime fin) {
    final dias = <DateTime>[];
    var fecha = DateTime(inicio.year, inicio.month, inicio.day);
    final finDate = DateTime(fin.year, fin.month, fin.day);

    while (fecha.isBefore(finDate) || fecha.isAtSameMomentAs(finDate)) {
      dias.add(fecha);
      fecha = fecha.add(const Duration(days: 1));
    }
    return dias;
  }

  static String _obtenerNombreDia(DateTime fecha, DateTime fechaInicio) {
    final diferencia = fecha
        .difference(
            DateTime(fechaInicio.year, fechaInicio.month, fechaInicio.day))
        .inDays;

    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Ayer';
    if (diferencia == 2) return 'Hace 2 días';
    if (diferencia == 3) return 'Hace 3 días';

    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
