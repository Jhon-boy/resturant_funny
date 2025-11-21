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
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadistica_card_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/reporte_data_table_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class SucursalMesaStats {
  final SucursalEntity sucursal;
  final List<MesaEntity> mesas;
  final int totalMesas;
  final int totalVentas;
  final double montoTotal;
  final double promedioVenta;
  final Map<int, int> ventasPorMesa; // idMesa -> cantidad ventas

  SucursalMesaStats({
    required this.sucursal,
    required this.mesas,
    required this.totalMesas,
    required this.totalVentas,
    required this.montoTotal,
    required this.promedioVenta,
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
  SucursalMesaStats? _sucursalTopVentas;

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
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
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

          // 2. Obtener todas las ventas (sin filtro de fecha para estadísticas generales)
          final ventasResult = await _ventaRepository.getVentas();

          await ventasResult.fold(
            (failure) async {
              DialogHelper.error(context,
                  message: failure.message, onConfirmed: () {});
              if (mounted) {
                ref.read(appStateProvider.notifier).setLoading(false);
              }
            },
            (todasLasVentas) async {
              _sucursalesStats.clear();

              // 3. Para cada sucursal, obtener sus mesas y calcular estadísticas
              for (final sucursal in sucursalesActivas) {
                final mesasResult = await _mesaRepository
                    .getMesasBySucursal(sucursal.idSucursal ?? 0);

                mesasResult.fold(
                  (failure) {},
                  (mesas) {
                    final idsMesas = mesas.map((m) => m.idMesa ?? 0).toList();

                    // Filtrar ventas de esta sucursal
                    final ventasSucursal = todasLasVentas
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
                      ventasPorMesa: ventasPorMesa,
                    ));
                  },
                );
              }

              // Ordenar sucursales por número de ventas descendente
              _sucursalesStats
                  .sort((a, b) => b.totalVentas.compareTo(a.totalVentas));

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
              Icon(Icons.analytics, color: ThemeApp.primary, size: 28),
              SizedBox(width: 12),
              Text(
                'Resumen General',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              EstadisticaCardWidget(
                titulo: 'Total Sucursales',
                icon: Icons.store,
                color: Colors.amber,
                valor: '$_totalSucursales',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Total Mesas',
                icon: Icons.table_restaurant,
                color: Colors.blue,
                valor: '$_totalMesas',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Total Ventas',
                icon: Icons.point_of_sale,
                color: ThemeApp.primary,
                valor: '$_totalVentasGeneral',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Monto Total',
                icon: Icons.attach_money,
                color: Colors.green,
                valor: '\$${_montoTotalGeneral.toStringAsFixed(2)}',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.point_of_sale,
                              size: 16, color: ThemeApp.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${_sucursalTopVentas!.totalVentas} ventas',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ThemeApp.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.attach_money,
                              size: 16, color: ThemeApp.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '\$${_sucursalTopVentas!.montoTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ThemeApp.textSecondary,
                            ),
                          ),
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
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildStatChip(
                      'Mesas',
                      '${stats.totalMesas}',
                      Icons.table_restaurant,
                      Colors.blue,
                    ),
                    _buildStatChip(
                      'Promedio',
                      '\$${stats.promedioVenta.toStringAsFixed(2)}',
                      Icons.trending_flat,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              // Tabla de mesas
              if (stats.mesas.isNotEmpty) ...[
                const Divider(height: 1),
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
                        'Número',
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
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
