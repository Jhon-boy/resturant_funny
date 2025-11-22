// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/grafico_ventas_widget.dart';

class SucursalVentasStats {
  final SucursalEntity sucursal;
  final int totalVentasUltimos3Dias;
  final double montoTotalUltimos3Dias;
  final double promedioVenta;
  final List<VentaDia> ventasPorDia;

  SucursalVentasStats({
    required this.sucursal,
    required this.totalVentasUltimos3Dias,
    required this.montoTotalUltimos3Dias,
    required this.promedioVenta,
    required this.ventasPorDia,
  });
}

class ResumenVentasWidget extends ConsumerStatefulWidget {
  const ResumenVentasWidget({super.key});

  @override
  ConsumerState<ResumenVentasWidget> createState() =>
      _ResumenVentasWidgetState();
}

class _ResumenVentasWidgetState extends ConsumerState<ResumenVentasWidget> {
  late VentaRepository _ventaRepository;
  late MesaRepository _mesaRepository;
  late SucursalRepository _sucursalRepository;

  List<SucursalVentasStats> _sucursalesStats = [];
  bool _loading = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _loading = true);

    try {
      final ahora = DateTime.now();
      final hace3Dias = ahora.subtract(const Duration(days: 3));
      final inicio3Dias =
          DateTime(hace3Dias.year, hace3Dias.month, hace3Dias.day);
      final fin3Dias = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);

      // 1. Obtener todas las sucursales activas
      final sucursalesResult = await _sucursalRepository.getSucursalesEntity();

      await sucursalesResult.fold(
        (failure) async {
          setState(() {
            _loading = false;
            _sucursalesStats = [];
          });
        },
        (todasLasSucursales) async {
          final sucursalesActivas =
              todasLasSucursales.where((s) => s.isActiva).toList();

          // 2. Obtener todas las ventas de los últimos 3 días
          final ventasUltimos3DiasResult = await _ventaRepository.getVentas(
            fechaDesde: inicio3Dias,
            fechaHasta: fin3Dias,
          );

          await ventasUltimos3DiasResult.fold(
            (failure) async {
              setState(() {
                _loading = false;
                _sucursalesStats = [];
              });
            },
            (todasLasVentas) async {
              _sucursalesStats.clear();

              // 3. Para cada sucursal, obtener sus mesas y filtrar ventas
              for (final sucursal in sucursalesActivas) {
                final mesasResult = await _mesaRepository
                    .getMesasBySucursal(sucursal.idSucursal ?? 0);

                await mesasResult.fold(
                  (failure) async {},
                  (mesas) async {
                    final idsMesas = mesas.map((m) => m.idMesa ?? 0).toList();

                    // Filtrar ventas de esta sucursal
                    final ventasSucursal = todasLasVentas
                        .where((v) => idsMesas.contains(v.idMesa))
                        .toList();

                    final totalVentasUltimos3Dias = ventasSucursal.length;
                    final montoTotalUltimos3Dias = ventasSucursal
                        .where((v) => v.total != null)
                        .map((v) => v.total!)
                        .fold(0.0, (a, b) => a + b);
                    final promedioVenta = totalVentasUltimos3Dias > 0
                        ? montoTotalUltimos3Dias / totalVentasUltimos3Dias
                        : 0.0;

                    // Agrupar ventas por día
                    final ventasPorDia = <VentaDia>[];
                    final diasNombre = ['Hace 3 días', 'Ayer', 'Hoy'];

                    for (int i = 0; i < 3; i++) {
                      final diaFecha = inicio3Dias.add(Duration(days: i));
                      final inicioDia = DateTime(
                          diaFecha.year, diaFecha.month, diaFecha.day, 0, 0, 0);
                      final finDia = DateTime(diaFecha.year, diaFecha.month,
                          diaFecha.day, 23, 59, 59);

                      final ventasDia = ventasSucursal.where((venta) {
                        if (venta.fecha == null) return false;
                        final fechaVenta = venta.fecha!;
                        return fechaVenta.isAfter(inicioDia
                                .subtract(const Duration(seconds: 1))) &&
                            fechaVenta.isBefore(
                                finDia.add(const Duration(seconds: 1)));
                      }).toList();

                      final numeroVentas = ventasDia.length;
                      final montoDia = ventasDia
                          .where((v) => v.total != null)
                          .map((v) => v.total!)
                          .fold(0.0, (a, b) => a + b);

                      ventasPorDia.add(VentaDia(
                        dia: diasNombre[i],
                        numeroVentas: numeroVentas,
                        montoTotal: montoDia,
                      ));
                    }

                    _sucursalesStats.add(SucursalVentasStats(
                      sucursal: sucursal,
                      totalVentasUltimos3Dias: totalVentasUltimos3Dias,
                      montoTotalUltimos3Dias: montoTotalUltimos3Dias,
                      promedioVenta: promedioVenta,
                      ventasPorDia: ventasPorDia,
                    ));
                  },
                );
              }

              setState(() {
                _loading = false;
              });
            },
          );
        },
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _sucursalesStats = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ShimmerWidget.list(itemCount: 2),
      );
    }

    if (_sucursalesStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A5F),
                Color(0xFF2E5C8A),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.dashboard, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Resumen de Ventas por Sucursal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Últimos 3 Días, desliza para ver cada sucursal',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _sucursalesStats.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final stats = _sucursalesStats[index];
              return _buildSucursalCard(stats);
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores de página
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _sucursalesStats.length,
            (index) => _buildPageIndicator(index),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      width: _currentPage == index ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? const Color(0xFF1E3A5F)
            : const Color(0xFF1E3A5F).withOpacity(0.1),
      ),
    );
  }

  Widget _buildSucursalCard(SucursalVentasStats stats) {
    final maxVentas = stats.ventasPorDia.isEmpty
        ? 1.0
        : stats.ventasPorDia
            .map((v) => v.numeroVentas)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header de la sucursal
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E3A5F),
                    const Color(0xFF2E5C8A).withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.store, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats.sucursal.nombre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (stats.sucursal.direccion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            stats.sucursal.direccion!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Ventas',
                    '${stats.totalVentasUltimos3Dias}',
                    Icons.point_of_sale,
                    const Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Monto Total',
                    '\$${stats.montoTotalUltimos3Dias.toStringAsFixed(2)}',
                    Icons.attach_money,
                    const Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Promedio',
                    '\$${stats.promedioVenta.toStringAsFixed(2)}',
                    Icons.trending_flat,
                    const Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Gráfico de ventas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A5F),
                    Color(0xFF2E5C8A),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: GraficoVentasWidget(
                ventasPorDia: stats.ventasPorDia,
                maxVentas: maxVentas,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
