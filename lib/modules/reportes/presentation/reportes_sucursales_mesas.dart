// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/reporte_data_table_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';

/// Modelo para estadísticas completas de sucursal
class SucursalMesaStats {
  final SucursalEntity sucursal;
  final List<MesaEntity> mesas;
  final int totalMesas;
  final int totalVentas;
  final double montoTotal;
  final double promedioVenta;
  final int totalClientes; // Clientes únicos
  final Map<int, int> ventasPorMesa; // idMesa -> cantidad ventas

  SucursalMesaStats({
    required this.sucursal,
    required this.mesas,
    required this.totalMesas,
    required this.totalVentas,
    required this.montoTotal,
    required this.promedioVenta,
    required this.totalClientes,
    required this.ventasPorMesa,
  });
}

class ReporteSucursalesMesasPage extends ConsumerStatefulWidget {
  const ReporteSucursalesMesasPage({super.key});

  @override
  ConsumerState<ReporteSucursalesMesasPage> createState() =>
      _ReporteSucursalesMesasPageState();
}

class _ReporteSucursalesMesasPageState
    extends ConsumerState<ReporteSucursalesMesasPage> {
  late VentaRepository _ventaRepository;
  late MesaRepository _mesaRepository;
  late SucursalRepository _sucursalRepository;

  List<SucursalMesaStats> _sucursalesStats = [];
  int _totalSucursales = 0;
  int _totalMesas = 0;
  int _totalVentasGeneral = 0;
  double _montoTotalGeneral = 0.0;
  int _totalClientesGeneral = 0;
  SucursalMesaStats? _sucursalTopVentas;

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  static const int MAX_DIAS = 30; // 1 mes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ventaRepository = VentaRepositoryImpl(
        VentasRemoteDataSource(ref: ref),
      );
      _mesaRepository = MesaRepositoryImpl(
        MesasRemoteDataSource(ref: ref),
      );
      _sucursalRepository = SucursalRemoteRepository(
        SucursalRemoteDataSource(ref: ref),
      );
      // Inicializar con el último mes
      final ahora = DateTime.now();
      _fechaFin = ahora;
      _fechaInicio = ahora.subtract(const Duration(days: MAX_DIAS - 1));
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    if (_fechaInicio == null || _fechaFin == null) {
      SnackHelper.show(context,
          message: 'Por favor seleccione un rango de fechas', isError: true);
      return;
    }

    // Validar que no exceda el máximo de días
    final diferencia = _fechaFin!.difference(_fechaInicio!).inDays + 1;
    if (diferencia > MAX_DIAS) {
      SnackHelper.show(context,
          message: 'El rango máximo es de $MAX_DIAS días', isError: true);
      return;
    }

    ref.read(appStateProvider.notifier).setLoading(true);

    try {
      // 1. Obtener todas las sucursales activas
      final sucursalesResult = await _sucursalRepository.getSucursalesEntity();

      await sucursalesResult.fold(
        (failure) async {
          DialogHelper.error(context,
              message: failure.message, onConfirmed: () {});
          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        (todasLasSucursales) async {
          final sucursalesActivas =
              todasLasSucursales.where((s) => s.isActiva).toList();

          final ventasResult = await _ventaRepository.getVentas(
            fechaDesde: _fechaInicio,
            fechaHasta: _fechaFin,
          );

          await ventasResult.fold(
            (failure) async {
              DialogHelper.error(context,
                  message: failure.message, onConfirmed: () {});
              if (mounted) {
                ref.read(appStateProvider.notifier).setLoading(false);
              }
            },
            (ventasEnRango) async {
              _sucursalesStats.clear();

              // 3. Para cada sucursal, obtener sus mesas y calcular estadísticas
              for (final sucursal in sucursalesActivas) {
                final mesasResult = await _mesaRepository
                    .getMesasBySucursal(sucursal.idSucursal ?? 0);

                mesasResult.fold(
                  (failure) {},
                  (mesas) {
                    final idsMesas = mesas.map((m) => m.idMesa ?? 0).toList();

                    // Filtrar ventas de esta sucursal (por mesas)
                    final ventasSucursal = ventasEnRango
                        .where((v) => idsMesas.contains(v.idMesa))
                        .toList();

                    // Calcular estadísticas de la sucursal
                    final totalVentas = ventasSucursal.length;
                    final montoTotal = ventasSucursal
                        .where((v) => v.total != null)
                        .map((v) => v.total!)
                        .fold(0.0, (a, b) => a + b);
                    final promedioVenta =
                        totalVentas > 0 ? montoTotal / totalVentas : 0.0;

                    // Clientes únicos de esta sucursal
                    final clientesUnicos = ventasSucursal
                        .where((v) => v.cliente.isNotEmpty)
                        .map((v) => v.cliente)
                        .toSet();
                    final totalClientes = clientesUnicos.length;

                    // Ventas por mesa
                    final ventasPorMesa = <int, int>{};
                    for (final venta in ventasSucursal) {
                      ventasPorMesa[venta.idMesa] =
                          (ventasPorMesa[venta.idMesa] ?? 0) + 1;
                    }

                    _sucursalesStats.add(SucursalMesaStats(
                      sucursal: sucursal,
                      mesas: mesas,
                      totalMesas: mesas.length,
                      totalVentas: totalVentas,
                      montoTotal: montoTotal,
                      promedioVenta: promedioVenta,
                      totalClientes: totalClientes,
                      ventasPorMesa: ventasPorMesa,
                    ));
                  },
                );
              }

              // Ordenar sucursales por monto total descendente
              _sucursalesStats
                  .sort((a, b) => b.montoTotal.compareTo(a.montoTotal));

              // Calcular estadísticas generales
              _totalSucursales = _sucursalesStats.length;
              _totalMesas = _sucursalesStats
                  .map((s) => s.totalMesas)
                  .fold(0, (a, b) => a + b);
              _totalVentasGeneral = _sucursalesStats
                  .map((s) => s.totalVentas)
                  .fold(0, (a, b) => a + b);
              _montoTotalGeneral = _sucursalesStats
                  .map((s) => s.montoTotal)
                  .fold(0.0, (a, b) => a + b);

              // Clientes únicos generales (de todas las sucursales)
              final clientesUnicosGeneral = ventasEnRango
                  .where((v) => v.cliente.isNotEmpty)
                  .map((v) => v.cliente)
                  .toSet();
              _totalClientesGeneral = clientesUnicosGeneral.length;

              _sucursalTopVentas =
                  _sucursalesStats.isNotEmpty ? _sucursalesStats.first : null;

              setState(() {});

              if (mounted) {
                ref.read(appStateProvider.notifier).setLoading(false);
              }
            },
          );
        },
      );
    } catch (e) {
      DialogHelper.error(context,
          message: 'Error inesperado: $e', onConfirmed: () {});
      if (mounted) {
        ref.read(appStateProvider.notifier).setLoading(false);
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
      title: 'Sucursales y Mesas',
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de rango de fechas
            DateRangeWidget(
              title: 'Rango de Fechas (Máximo 1 mes)',
              startDate: _fechaInicio,
              endDate: _fechaFin,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now(),
              onDateRangeSelected: (inicio, fin) {
                if (inicio != null && fin != null) {
                  final diferencia = fin.difference(inicio).inDays + 1;
                  if (diferencia > MAX_DIAS) {
                    SnackHelper.show(context,
                        message: 'El rango máximo es de 1 mes (30 días)',
                        isError: true);
                    return;
                  }
                  setState(() {
                    _fechaInicio = inicio;
                    _fechaFin = fin;
                  });
                  _cargarDatos();
                }
              },
            ),
            const SizedBox(height: 24),
            // Contenido del reporte
            _buildContenidoReporte(),
            const SizedBox(height: 24),
            // Botón para generar PDF
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

  Widget _buildContenidoReporte() {
    return ref.watch(appStateProvider).isLoading
        ? Center(child: ShimmerWidget.list(itemCount: 3))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstadisticas(),
              const SizedBox(height: 24),
              _buildGraficoComparativo(),
              const SizedBox(height: 24),
              _buildSucursalTop(),
              const SizedBox(height: 24),
              _buildTablaSucursales(),
            ],
          );
  }

  Widget _buildEstadisticas() {
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
              Icon(Icons.analytics, color: ThemeApp.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Resumen General',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow('Total Sucursales', '$_totalSucursales'),
          _buildStatRow('Total Mesas', '$_totalMesas'),
          _buildStatRow('Total Ventas', '$_totalVentasGeneral'),
          _buildStatRow(
              'Monto Total', '\$${_montoTotalGeneral.toStringAsFixed(2)}'),
          _buildStatRow('Total Clientes', '$_totalClientesGeneral'),
          _buildStatRow(
            'Promedio General',
            _totalVentasGeneral > 0
                ? '\$${(_montoTotalGeneral / _totalVentasGeneral).toStringAsFixed(2)}'
                : '\$0.00',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeApp.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemeApp.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoComparativo() {
    if (_sucursalesStats.isEmpty) {
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

    // Ordenar por monto total descendente para mejor visualización
    final statsOrdenados = List<SucursalMesaStats>.from(_sucursalesStats)
      ..sort((a, b) => b.montoTotal.compareTo(a.montoTotal));

    final maxVentas = statsOrdenados
        .map((s) => s.totalVentas)
        .reduce((a, b) => a > b ? a : b);
    final maxMonto =
        statsOrdenados.map((s) => s.montoTotal).reduce((a, b) => a > b ? a : b);

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
                'Comparativo por Sucursal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Gráfico de barras mejorado
          SizedBox(
            height: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: statsOrdenados.asMap().entries.map((entry) {
                final index = entry.key;
                final stats = entry.value;

                final alturaVentas =
                    maxVentas > 0 ? (stats.totalVentas / maxVentas * 320) : 0.0;
                final alturaMonto =
                    maxMonto > 0 ? (stats.montoTotal / maxMonto * 320) : 0.0;

                // Colores alternados para mejor diferenciación
                final colorVentas = [
                  ThemeApp.primary,
                  Colors.blue,
                  Colors.teal,
                  Colors.orange,
                  Colors.purple,
                ][index % 5];

                final colorMonto = [
                  Colors.green,
                  Colors.lightGreen,
                  Colors.greenAccent,
                  Colors.teal,
                  Colors.cyan,
                ][index % 5];

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Información superior
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorMonto.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colorMonto.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '\$${stats.montoTotal.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: colorMonto,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${stats.totalVentas} ventas',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: colorVentas,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                  margin: const EdgeInsets.only(right: 2),
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
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorVentas.withOpacity(0.3),
                                        blurRadius: 4,
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
                                  margin: const EdgeInsets.only(left: 2),
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
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorMonto.withOpacity(0.3),
                                        blurRadius: 4,
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
                        const SizedBox(height: 8),
                        // Nombre de la sucursal
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          decoration: BoxDecoration(
                            color: ThemeApp.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            stats.sucursal.nombre,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: ThemeApp.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          // Leyenda mejorada
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

  Widget _buildSucursalTop() {
    if (_sucursalTopVentas == null) {
      return const SizedBox.shrink();
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
              Icon(Icons.star, color: ThemeApp.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Sucursal con Más Ventas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeApp.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.store, color: ThemeApp.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sucursalTopVentas!.sucursal.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeApp.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          _buildStatRow('Total Ventas',
                              '${_sucursalTopVentas!.totalVentas}'),
                          _buildStatRow('Monto Total',
                              '\$${_sucursalTopVentas!.montoTotal.toStringAsFixed(2)}'),
                          _buildStatRow('Total Clientes',
                              '${_sucursalTopVentas!.totalClientes}'),
                          _buildStatRow('Promedio Venta',
                              '\$${_sucursalTopVentas!.promedioVenta.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTablaSucursales() {
    if (_sucursalesStats.isEmpty) {
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
        child: const Column(
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: ThemeApp.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron sucursales',
              style: TextStyle(
                fontSize: 16,
                color: ThemeApp.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _sucursalesStats.map((stats) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
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
              // Encabezado de sucursal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ThemeApp.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.store, color: ThemeApp.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stats.sucursal.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemeApp.textPrimary,
                            ),
                          ),
                          if (stats.sucursal.direccion != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              stats.sucursal.direccion!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: ThemeApp.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.point_of_sale,
                                size: 16, color: ThemeApp.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${stats.totalVentas} ventas',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ThemeApp.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.attach_money,
                                size: 16, color: ThemeApp.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '\$${stats.montoTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ThemeApp.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Estadísticas de la sucursal
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatRow('Total Mesas', '${stats.totalMesas}'),
                    _buildStatRow('Total Clientes', '${stats.totalClientes}'),
                    _buildStatRow('Total Ventas', '${stats.totalVentas}'),
                    _buildStatRow('Monto Total',
                        '\$${stats.montoTotal.toStringAsFixed(2)}'),
                    _buildStatRow('Promedio Venta',
                        '\$${stats.promedioVenta.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const Divider(height: 1),
              const Column(children: [Text('Mesas de la Sucursal')]),
              const SizedBox(height: 16),
              ReporteDataTableWidget(
                titulo: 'Mesas de la Sucursal',
                icono: Icons.table_chart,
                mensajeVacio: 'No hay mesas en esta sucursal',
                mostrarTitulo: false,
                columns: const [
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Sillas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Estado',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total Ventas',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: stats.mesas.map((mesa) {
                  final ventasMesa = stats.ventasPorMesa[mesa.idMesa] ?? 0;
                  return DataRow(
                    cells: [
                      DataCell(Text('${mesa.idMesa ?? 'N/A'}')),
                      DataCell(Text('${mesa.numero ?? 'N/A'}')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: mesa.estado == 'DISPONIBLE'
                                    ? Colors.green
                                    : mesa.estado == 'OCUPADA'
                                        ? Colors.orange
                                        : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(mesa.estado ?? 'N/A'),
                          ],
                        ),
                      ),
                      DataCell(Text('$ventasMesa')),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
