// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadistica_card_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/reporte_data_table_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class EmpleadoVentasStats {
  final int idEmpleado;
  final String nombre;
  final int totalVentas;
  final double montoTotal;
  final double promedioVenta;

  EmpleadoVentasStats({
    required this.idEmpleado,
    required this.nombre,
    required this.totalVentas,
    required this.montoTotal,
    required this.promedioVenta,
  });
}

class ReporteVentasPorEmpleadoPage extends ConsumerStatefulWidget {
  const ReporteVentasPorEmpleadoPage({super.key, required this.sucursales});
  final List<SucursalEntity> sucursales;

  @override
  ConsumerState<ReporteVentasPorEmpleadoPage> createState() =>
      _ReporteVentasPorEmpleadoPageState();
}

class _ReporteVentasPorEmpleadoPageState
    extends ConsumerState<ReporteVentasPorEmpleadoPage> {
  late VentaRepository _ventaRepository;
  late MesaRepository _mesaRepository;
  late PersonasRemoteDataSource _personasDataSource;
  late UsuariosRemoteDataSource _usuariosDataSource;

  // Filtros
  SucursalEntity? _sucursalSeleccionada;
  DateTime? _fechaInicio;
  DateTime? _fechaHasta;

  List<EmpleadoVentasStats> _empleadosStats = [];
  int _totalEmpleados = 0;
  int _totalVentasGeneral = 0;
  double _montoTotalGeneral = 0.0;

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
      _personasDataSource = PersonasRemoteDataSource(ref: ref);
      _usuariosDataSource = UsuariosRemoteDataSource(ref: ref);
    });
  }

  Future<void> _cargarDatos() async {
    if (_sucursalSeleccionada == null) {
      DialogHelper.error(context,
          message: 'Por favor seleccione una sucursal', onConfirmed: () {});
      return;
    }

    if (_fechaInicio == null || _fechaHasta == null) {
      DialogHelper.error(context,
          message: 'Por favor seleccione el rango de fechas',
          onConfirmed: () {});
      return;
    }

    final diferencia = _fechaHasta!.difference(_fechaInicio!);
    if (diferencia.inDays > 3) {
      DialogHelper.error(context,
          message: 'El rango máximo es de 3 días', onConfirmed: () {});
      return;
    }

    ref.read(appStateProvider.notifier).setLoading(true);

    try {
      // 1. Obtener mesas de la sucursal
      final mesasResult = await _mesaRepository.getMesasBySucursal(
        _sucursalSeleccionada!.idSucursal ?? 0,
      );

      mesasResult.fold(
        (failure) {
          DialogHelper.error(context,
              message: failure.message, onConfirmed: () {});
          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        (mesas) async {
          if (mesas.isEmpty) {
            setState(() {
              _empleadosStats = [];
              _totalEmpleados = 0;
              _totalVentasGeneral = 0;
              _montoTotalGeneral = 0.0;
            });
            if (mounted) {
              ref.read(appStateProvider.notifier).setLoading(false);
            }
            return;
          }

          final idsMesas = mesas.map((m) => m.idMesa ?? 0).toList();

          // 2. Obtener todas las ventas y filtrar por mesas y fechas
          final ventasResult = await _ventaRepository.getVentas(
            fechaDesde: _fechaInicio,
            fechaHasta: _fechaHasta?.add(const Duration(days: 1)),
          );

          await ventasResult.fold(
            (failure) async {
              DialogHelper.error(context,
                  message: failure.message, onConfirmed: () {});
              if (mounted) {
                ref.read(appStateProvider.notifier).setLoading(false);
              }
            },
            (todasLasVentas) async {
              // Filtrar ventas por mesas de la sucursal
              final ventasFiltradas = todasLasVentas
                  .where((v) => idsMesas.contains(v.idMesa))
                  .toList();

              // 3. Agrupar ventas por empleado
              final ventasPorEmpleado = <int, List<dynamic>>{};
              for (final venta in ventasFiltradas) {
                if (!ventasPorEmpleado.containsKey(venta.idEmpleado)) {
                  ventasPorEmpleado[venta.idEmpleado] = [];
                }
                ventasPorEmpleado[venta.idEmpleado]!.add(venta);
              }

              // 4. Calcular estadísticas por empleado
              _empleadosStats.clear();
              final empleadosUnicos = ventasPorEmpleado.keys.toSet();

              for (final idEmpleado in empleadosUnicos) {
                final ventasEmpleado = ventasPorEmpleado[idEmpleado]!;
                final totalVentas = ventasEmpleado.length;
                final montoTotal = ventasEmpleado
                    .where((v) => (v as dynamic).total != null)
                    .map((v) => (v as dynamic).total as double)
                    .fold(0.0, (a, b) => a + b);
                final promedioVenta =
                    totalVentas > 0 ? montoTotal / totalVentas : 0.0;

                // Obtener nombre del empleado
                String nombreEmpleado = 'Empleado #$idEmpleado';
                try {
                  final usuarioResult =
                      await _usuariosDataSource.getUsuarioById(idEmpleado);
                  if (usuarioResult != null) {
                    final personaResult = await _personasDataSource
                        .getPersonaById(usuarioResult.identificacion);
                    if (personaResult != null) {
                      nombreEmpleado =
                          '${personaResult.nombres} ${personaResult.apellidos}';
                    }
                  }
                } catch (e) {
                  // Mantener nombre por defecto
                }

                _empleadosStats.add(EmpleadoVentasStats(
                  idEmpleado: idEmpleado,
                  nombre: nombreEmpleado,
                  totalVentas: totalVentas,
                  montoTotal: montoTotal,
                  promedioVenta: promedioVenta,
                ));
              }

              // Ordenar por número de ventas descendente
              _empleadosStats
                  .sort((a, b) => b.totalVentas.compareTo(a.totalVentas));

              // Calcular totales generales
              _totalEmpleados = _empleadosStats.length;
              _totalVentasGeneral = ventasFiltradas.length;
              _montoTotalGeneral = ventasFiltradas
                  .where((v) => v.total != null)
                  .map((v) => v.total!)
                  .fold(0.0, (a, b) => a + b);

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
      title: 'Ventas por Empleado',
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros
            _buildFiltros(),
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

  Widget _buildFiltros() {
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
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeApp.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          CustomDropdown<SucursalEntity>(
            label: 'Sucursal',
            value: _sucursalSeleccionada,
            items: widget.sucursales,
            displayText: (sucursal) => sucursal.nombre,
            hint: 'Seleccione una sucursal',
            onChanged: (sucursal) {
              setState(() {
                _sucursalSeleccionada = sucursal;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CalendarWidget(
                  title: 'Fecha Inicio',
                  selectedDate: _fechaInicio,
                  onDateSelected: (fecha) {
                    setState(() {
                      _fechaInicio = fecha;
                      if (_fechaHasta != null && _fechaInicio != null) {
                        final diferencia =
                            _fechaHasta!.difference(_fechaInicio!);
                        final diasDiferencia = diferencia.inDays;
                        if (diasDiferencia > 3) {
                          _fechaHasta =
                              _fechaInicio!.add(const Duration(days: 3));
                          if (_fechaHasta != null &&
                              _fechaHasta!.isAfter(DateTime.now())) {
                            _fechaHasta = DateTime.now();
                          }
                        }
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CalendarWidget(
                  title: 'Fecha Hasta',
                  selectedDate: _fechaHasta,
                  onDateSelected: (fecha) {
                    setState(() {
                      if (_fechaInicio != null &&
                          fecha != null &&
                          fecha.isBefore(_fechaInicio!)) {
                        DialogHelper.info(context,
                            message:
                                'La fecha hasta debe ser posterior a la fecha inicio',
                            onConfirmed: () {});
                        return;
                      }
                      _fechaHasta = fecha;
                      if (_fechaHasta != null &&
                          _fechaHasta!.isAfter(DateTime.now())) {
                        _fechaHasta = DateTime.now();
                      }
                      if (_fechaInicio != null && _fechaHasta != null) {
                        final diferencia =
                            _fechaHasta!.difference(_fechaInicio!);
                        final diasDiferencia = diferencia.inDays;
                        if (diasDiferencia > 3) {
                          DialogHelper.info(context,
                              message: 'El rango máximo es de 3 días',
                              onConfirmed: () {});
                          _fechaHasta =
                              _fechaInicio!.add(const Duration(days: 3));
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          if (_fechaInicio != null && _fechaHasta != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeApp.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: ThemeApp.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Rango seleccionado: ${_fechaHasta!.difference(_fechaInicio!).inDays} días',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeApp.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: 'Buscar',
            colorButton: ThemeApp.primary,
            colorText: Colors.white,
            icon: Icons.search,
            onPressed: _cargarDatos,
          ),
        ],
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
              _buildTablaEmpleados(),
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
                titulo: 'Total Empleados',
                icon: Icons.people,
                color: Colors.blue,
                valor: '$_totalEmpleados',
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

  Widget _buildTablaEmpleados() {
    if (_empleadosStats.isEmpty) {
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
              Icons.people_outline,
              size: 64,
              color: ThemeApp.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontraron ventas de empleados en el período seleccionado',
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

    return ReporteDataTableWidget(
      titulo: 'Ventas por Empleado',
      icono: Icons.table_chart,
      mensajeVacio:
          'No se encontraron ventas de empleados en el período seleccionado',
      columns: const [
        DataColumn(
          label: Text(
            'ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Empleado',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Total Ventas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Monto Total',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Promedio por Venta',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: _empleadosStats.map((stats) {
        return DataRow(
          cells: [
            DataCell(Text('${stats.idEmpleado}')),
            DataCell(Text(stats.nombre)),
            DataCell(Text('${stats.totalVentas}')),
            DataCell(Text('\$${stats.montoTotal.toStringAsFixed(2)}')),
            DataCell(Text('\$${stats.promedioVenta.toStringAsFixed(2)}')),
          ],
        );
      }).toList(),
    );
  }
}
