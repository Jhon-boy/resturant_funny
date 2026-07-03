/// Modelo para estadísticas de ventas por día
class VentaDiaStats {
  final String dia;
  final DateTime fecha;
  final int numeroVentas;
  final double montoTotal;
  final int numeroFacturas;

  VentaDiaStats({
    required this.dia,
    required this.fecha,
    required this.numeroVentas,
    required this.montoTotal,
    required this.numeroFacturas,
  });
}

/// Modelo para estadísticas de ventas por empleado
class VentaEmpleadoStats {
  final int idEmpleado;
  final String nombreEmpleado;
  final int totalVentas;
  final double montoTotal;

  VentaEmpleadoStats({
    required this.idEmpleado,
    required this.nombreEmpleado,
    required this.totalVentas,
    required this.montoTotal,
  });
}

/// Modelo para estadísticas de ventas por cliente
class VentaClienteStats {
  final String identificacionCliente;
  final String nombreCliente;
  final int totalCompras;
  final double montoTotal;

  VentaClienteStats({
    required this.identificacionCliente,
    required this.nombreCliente,
    required this.totalCompras,
    required this.montoTotal,
  });
}

/// Modelo para estadísticas de mesa
class MesaStats {
  final int idMesa;
  final String nombreMesa;
  final int totalVentas;
  final double montoTotal;

  MesaStats({
    required this.idMesa,
    required this.nombreMesa,
    required this.totalVentas,
    required this.montoTotal,
  });
}

/// Modelo para estadísticas de porciones
class PorcionStats {
  final int idProducto;
  final String nombreProducto;
  final int cantidadVendida;
  final double montoTotal;

  PorcionStats({
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidadVendida,
    required this.montoTotal,
  });
}

/// Modelo para productos con cantidad de ventas
class ProductoVentaCount {
  final int idProducto;
  final String nombreProducto;
  final int cantidadVentas; // Cuántas veces se vendió este producto
  final int cantidadUnidades; // Total de unidades vendidas
  final double montoTotal;

  ProductoVentaCount({
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidadVentas,
    required this.cantidadUnidades,
    required this.montoTotal,
  });
}

/// Modelo para desglose de recaudación por método de pago
class MetodoPagoStats {
  final String metodoPago;
  final int totalTransacciones;
  final double montoTotal;

  MetodoPagoStats({
    required this.metodoPago,
    required this.totalTransacciones,
    required this.montoTotal,
  });
}

/// Modelo completo de estadísticas de ventas
class EstadisticasVentasCompletas {
  // Estadísticas básicas
  final int totalVentas;
  final double montoTotalVendido;
  final double promedioVenta;
  final int totalFacturas;
  final double montoTotalFacturado;

  // Por día
  final List<VentaDiaStats> ventasPorDia;
  final double promedioPorDia;

  // Por empleado
  final List<VentaEmpleadoStats> ventasPorEmpleado;
  final VentaEmpleadoStats? empleadoTop;

  // Por cliente
  final List<VentaClienteStats> ventasPorCliente;
  final VentaClienteStats? clienteTop;

  // Por mesa
  final List<MesaStats> ventasPorMesa;
  final MesaStats? mesaTop;

  // Por tipo de venta
  final Map<String, int> ventasPorTipo;

  // Productos (solo PRODUCTO y COMIDA)
  final Map<int, int> productosVendidos;
  final Map<int, String> nombresProductos;

  // Productos con cantidad de ventas
  final List<ProductoVentaCount> productosConVentas;

  // Porciones
  final List<PorcionStats> porcionesVendidas;
  final PorcionStats? porcionTop;

  // Estadísticas adicionales
  final double ticketPromedio;
  final int ventasConDelivery;
  final double montoTotalDelivery;

  // Desglose por método de pago
  final List<MetodoPagoStats> ventasPorMetodoPago;

  EstadisticasVentasCompletas({
    required this.totalVentas,
    required this.montoTotalVendido,
    required this.promedioVenta,
    required this.totalFacturas,
    required this.montoTotalFacturado,
    required this.ventasPorDia,
    required this.promedioPorDia,
    required this.ventasPorEmpleado,
    this.empleadoTop,
    required this.ventasPorCliente,
    this.clienteTop,
    required this.ventasPorMesa,
    this.mesaTop,
    required this.ventasPorTipo,
    required this.productosVendidos,
    required this.nombresProductos,
    required this.productosConVentas,
    required this.porcionesVendidas,
    this.porcionTop,
    required this.ticketPromedio,
    required this.ventasConDelivery,
    required this.montoTotalDelivery,
    required this.ventasPorMetodoPago,
  });
}
