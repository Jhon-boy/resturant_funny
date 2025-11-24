// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadisticas_basicas_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

/// Modelo para estadísticas mensuales
class EstadisticaMensual {
  final int mes;
  final String nombreMes;
  final int totalVentas;
  final double montoTotal;
  final double promedioVenta;
  final int totalClientes;
  final int totalFacturas;
  final double montoFacturado;

  EstadisticaMensual({
    required this.mes,
    required this.nombreMes,
    required this.totalVentas,
    required this.montoTotal,
    required this.promedioVenta,
    required this.totalClientes,
    required this.totalFacturas,
    required this.montoFacturado,
  });
}

class ReporteResumenComparativasPage extends ConsumerStatefulWidget {
  const ReporteResumenComparativasPage({super.key});

  @override
  ConsumerState<ReporteResumenComparativasPage> createState() =>
      _ReporteResumenComparativasPageState();
}

class _ReporteResumenComparativasPageState
    extends ConsumerState<ReporteResumenComparativasPage> {
  late VentaRepository _ventaRepository;

  final List<EstadisticaMensual> _estadisticasMensuales = [];
  final int _anoActual = DateTime.now().year;
  bool _loading = false;

  // Totales del año
  int _totalVentasAnual = 0;
  double _montoTotalAnual = 0.0;
  double _promedioAnual = 0.0;
  int _totalClientesAnual = 0;
  int _totalFacturasAnual = 0;
  double _montoFacturadoAnual = 0.0;

  // Mejor y peor mes
  EstadisticaMensual? _mejorMes;
  EstadisticaMensual? _peorMes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ventaRepository = VentaRepositoryImpl(
        VentasRemoteDataSource(ref: ref),
      );
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final inicioAno = DateTime(_anoActual, 1, 1);
      final finAno = DateTime(_anoActual, 12, 31, 23, 59, 59);

      // Obtener todas las ventas del ano actual
      final ventasResult = await _ventaRepository.getVentas(
        fechaDesde: inicioAno,
        fechaHasta: finAno,
      );

      await ventasResult.fold(
        (failure) async {
          if (mounted) {
            DialogHelper.error(context,
                message: failure.message, onConfirmed: () {});
            setState(() => _loading = false);
          }
        },
        (todasLasVentas) async {
          _estadisticasMensuales.clear();

          // Nombres de los meses
          final nombresMeses = [
            'Enero',
            'Febrero',
            'Marzo',
            'Abril',
            'Mayo',
            'Junio',
            'Julio',
            'Agosto',
            'Septiembre',
            'Octubre',
            'Noviembre',
            'Diciembre'
          ];

          // Procesar cada mes del ano
          for (int mes = 1; mes <= 12; mes++) {
            // Filtrar ventas del mes
            final ventasMes = todasLasVentas.where((venta) {
              final fechaVenta = venta.fCreacion ?? venta.fecha;
              if (fechaVenta == null) return false;

              return fechaVenta.year == _anoActual && fechaVenta.month == mes;
            }).toList();

            // Calcular estadísticas del mes
            final totalVentas = ventasMes.length;
            final montoTotal = ventasMes
                .where((v) => v.total != null)
                .map((v) => v.total!)
                .fold(0.0, (a, b) => a + b);
            final promedioVenta =
                totalVentas > 0 ? montoTotal / totalVentas : 0.0;

            // Clientes únicos del mes
            final clientesUnicos = ventasMes
                .where((v) => v.cliente.isNotEmpty)
                .map((v) => v.cliente)
                .toSet();
            final totalClientes = clientesUnicos.length;

            // Facturas del mes (ventas con CONFACTURA = true)
            final ventasConFactura =
                ventasMes.where((v) => v.conFactura == true).toList();
            final totalFacturas = ventasConFactura.length;
            final montoFacturado = ventasConFactura
                .where((v) => v.total != null)
                .map((v) => v.total!)
                .fold(0.0, (a, b) => a + b);

            _estadisticasMensuales.add(EstadisticaMensual(
              mes: mes,
              nombreMes: nombresMeses[mes - 1],
              totalVentas: totalVentas,
              montoTotal: montoTotal,
              promedioVenta: promedioVenta,
              totalClientes: totalClientes,
              totalFacturas: totalFacturas,
              montoFacturado: montoFacturado,
            ));
          }

          // Calcular totales del ano
          _totalVentasAnual = _estadisticasMensuales
              .map((e) => e.totalVentas)
              .fold(0, (a, b) => a + b);
          _montoTotalAnual = _estadisticasMensuales
              .map((e) => e.montoTotal)
              .fold(0.0, (a, b) => a + b);
          _promedioAnual = _totalVentasAnual > 0
              ? _montoTotalAnual / _totalVentasAnual
              : 0.0;

          // Clientes unicos del ano
          final clientesUnicosAnual = todasLasVentas
              .where((v) => v.cliente.isNotEmpty)
              .map((v) => v.cliente)
              .toSet();
          _totalClientesAnual = clientesUnicosAnual.length;

          // Facturas del ano
          final ventasConFacturaAnual =
              todasLasVentas.where((v) => v.conFactura == true).toList();
          _totalFacturasAnual = ventasConFacturaAnual.length;
          _montoFacturadoAnual = ventasConFacturaAnual
              .where((v) => v.total != null)
              .map((v) => v.total!)
              .fold(0.0, (a, b) => a + b);

          // Ordenar meses cronológicamente (Enero a Diciembre)
          _estadisticasMensuales.sort((a, b) => a.mes.compareTo(b.mes));

          // Encontrar mejor y peor mes (por monto total)
          if (_estadisticasMensuales.isNotEmpty) {
            final mesesOrdenadosPorMonto =
                List<EstadisticaMensual>.from(_estadisticasMensuales)
                  ..sort((a, b) => b.montoTotal.compareTo(a.montoTotal));
            _mejorMes = mesesOrdenadosPorMonto.first;
            _peorMes = mesesOrdenadosPorMonto.last;
          }

          if (mounted) {
            setState(() => _loading = false);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        DialogHelper.error(context,
            message: 'Error inesperado: $e', onConfirmed: () {});
        setState(() => _loading = false);
      }
    }
  }

  void _generarPDF() {
    DialogHelper.info(context,
        message: 'Generación de PDF próximamente', onConfirmed: () {});
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: 'Resumen Comparativas - Ano $_anoActual',
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? Center(child: ShimmerWidget.list(itemCount: 3))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEstadisticasAnuales(),
                  const SizedBox(height: 24),
                  _buildMejorPeorMes(),
                  const SizedBox(height: 24),
                  _buildGraficoMensual(),
                  const SizedBox(height: 24),
                  _buildTablaMensual(),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Generar PDF',
                    colorButton: ThemeApp.primary,
                    colorText: Colors.white,
                    icon: Icons.picture_as_pdf,
                    onPressed: _generarPDF,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEstadisticasAnuales() {
    return EstadisticasBasicasWidget(
      titulo: 'Resumen Anual $_anoActual',
      icono: Icons.calendar_today,
      estadisticas: [
        EstadisticaBasica(
          titulo: 'Total Ventas',
          valor: '$_totalVentasAnual',
          icon: Icons.point_of_sale,
          color: ThemeApp.primary,
        ),
        EstadisticaBasica(
          titulo: 'Monto Total',
          valor: '\$${_montoTotalAnual.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        EstadisticaBasica(
          titulo: 'Promedio Anual',
          valor: '\$${_promedioAnual.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
        EstadisticaBasica(
          titulo: 'Total Clientes',
          valor: '$_totalClientesAnual',
          icon: Icons.people,
          color: Colors.purple,
        ),
        EstadisticaBasica(
          titulo: 'Total Facturas',
          valor: '$_totalFacturasAnual',
          icon: Icons.receipt,
          color: Colors.blue,
        ),
        EstadisticaBasica(
          titulo: 'Monto Facturado',
          valor: '\$${_montoFacturadoAnual.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMejorPeorMes() {
    if (_mejorMes == null || _peorMes == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Mejor Mes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _mejorMes!.nombreMes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatRow('Ventas', '${_mejorMes!.totalVentas}'),
                _buildStatRow(
                    'Monto', '\$${_mejorMes!.montoTotal.toStringAsFixed(2)}'),
                _buildStatRow('Promedio',
                    '\$${_mejorMes!.promedioVenta.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_down, color: Colors.red, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Peor Mes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _peorMes!.nombreMes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatRow('Ventas', '${_peorMes!.totalVentas}'),
                _buildStatRow(
                    'Monto', '\$${_peorMes!.montoTotal.toStringAsFixed(2)}'),
                _buildStatRow('Promedio',
                    '\$${_peorMes!.promedioVenta.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: ThemeApp.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ThemeApp.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoMensual() {
    if (_estadisticasMensuales.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVentas = _estadisticasMensuales
        .map((e) => e.totalVentas)
        .reduce((a, b) => a > b ? a : b);
    final maxMonto = _estadisticasMensuales
        .map((e) => e.montoTotal)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: ThemeApp.primary, size: 28),
              SizedBox(width: 12),
              Text(
                'Comparativo Mensual',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 350,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _estadisticasMensuales.asMap().entries.map((entry) {
                final index = entry.key;
                final estadistica = entry.value;

                final alturaVentas = maxVentas > 0
                    ? (estadistica.totalVentas / maxVentas * 280)
                    : 0.0;
                final alturaMonto = maxMonto > 0
                    ? (estadistica.montoTotal / maxMonto * 280)
                    : 0.0;

                // Colores alternados
                final colorVentas = [
                  ThemeApp.primary,
                  Colors.blue,
                  Colors.teal,
                  Colors.orange,
                  Colors.purple,
                  Colors.pink,
                  Colors.indigo,
                  Colors.cyan,
                  Colors.amber,
                  Colors.deepOrange,
                  Colors.lightBlue,
                  Colors.green,
                ][index % 12];

                final colorMonto = [
                  Colors.green,
                  Colors.lightGreen,
                  Colors.greenAccent,
                  Colors.teal,
                  Colors.cyan,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.indigo,
                  Colors.purple,
                  Colors.pink,
                  Colors.orange,
                  Colors.deepOrange,
                ][index % 12];

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Información superior
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorMonto.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: colorMonto.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '\$${estadistica.montoTotal.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: colorMonto,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${estadistica.totalVentas}',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: colorVentas,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Barras del gráfico
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Barra de ventas
                              Flexible(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 1),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        colorVentas,
                                        colorVentas.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorVentas.withOpacity(0.3),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  height: alturaVentas > 0 ? alturaVentas : 2,
                                ),
                              ),
                              // Barra de monto
                              Flexible(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 1),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        colorMonto,
                                        colorMonto.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorMonto.withOpacity(0.3),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  height: alturaMonto > 0 ? alturaMonto : 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Nombre del mes (abreviado)
                        Text(
                          estadistica.nombreMes.substring(0, 3),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: ThemeApp.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Leyenda
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeApp.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                    'Ventas', ThemeApp.primary, Icons.point_of_sale),
                const SizedBox(width: 24),
                _buildLegendItem('Monto', Colors.green, Icons.attach_money),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTablaMensual() {
    if (_estadisticasMensuales.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No hay datos para mostrar',
            style: TextStyle(
              fontSize: 16,
              color: ThemeApp.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.table_chart, color: ThemeApp.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Detalle Mensual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._estadisticasMensuales.map((estadistica) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeApp.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ThemeApp.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        estadistica.nombreMes,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeApp.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ThemeApp.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${estadistica.montoTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Total Ventas', '${estadistica.totalVentas}'),
                  _buildStatRow('Promedio Venta',
                      '\$${estadistica.promedioVenta.toStringAsFixed(2)}'),
                  _buildStatRow(
                      'Total Clientes', '${estadistica.totalClientes}'),
                  _buildStatRow(
                      'Total Facturas', '${estadistica.totalFacturas}'),
                  _buildStatRow('Monto Facturado',
                      '\$${estadistica.montoFacturado.toStringAsFixed(2)}'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
