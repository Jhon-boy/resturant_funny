// ignore_for_file: use_build_context_synchronously, constant_identifier_names

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
import 'package:resturant_funny/modules/user/data/repository/persona_repository_impl.dart';
import 'package:resturant_funny/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/repository/persona_repository.dart';
import 'package:resturant_funny/modules/user/domain/repository/usuario_repository.dart';
import 'package:resturant_funny/modules/user/domain/models/empleados_model.dart';
import 'package:resturant_funny/modules/user/presentation/empleado_estadisticas_page.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadisticas_basicas_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class EmpleadoVentasStats {
  final int idEmpleado;
  final String nombre;
  final String identificacion;
  final int totalVentas;
  final double montoTotal;
  final double promedioVenta;
  final EmpleadoModel? empleadoModel;

  EmpleadoVentasStats({
    required this.idEmpleado,
    required this.nombre,
    required this.identificacion,
    required this.totalVentas,
    required this.montoTotal,
    required this.promedioVenta,
    this.empleadoModel,
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
  late PersonasRepository _personasRepository;
  late UsuariosRepository _usuariosRepository;

  // Filtros
  SucursalEntity? _sucursalSeleccionada;
  DateTime? _fechaInicio;
  DateTime? _fechaHasta;

  // Lista de todos los empleados de la sucursal
  List<EmpleadoModel> _todosLosEmpleados = [];
  List<EmpleadoVentasStats> _empleadosStats = [];
  int _totalEmpleados = 0;
  int _totalVentasGeneral = 0;
  double _montoTotalGeneral = 0.0;
  static const int MAX_DIAS = 30;

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
      _personasRepository = PersonaRepositoryImpl(
        PersonasRemoteDataSource(ref: ref),
      );
      _usuariosRepository = UsuariosRepositoryImpl(
        UsuariosRemoteDataSource(ref: ref),
      );
    });
  }

  // Cargar todos los empleados de la sucursal (sin filtrar por fechas)
  Future<void> _cargarEmpleados() async {
    if (_sucursalSeleccionada == null) {
      return;
    }

    ref.read(appStateProvider.notifier).setLoading(true);

    try {
      final usuariosResult = await _usuariosRepository.getUsuariosBySucursal(
        _sucursalSeleccionada!.idSucursal ?? 0,
      );

      await usuariosResult.fold(
        (failure) async {
          DialogHelper.error(context,
              message: failure.message, onConfirmed: () {});
          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        (todosLosUsuarios) async {
          _todosLosEmpleados.clear();
          _totalEmpleados = todosLosUsuarios.length;

          // Construir EmpleadoModel para cada usuario
          for (final usuario in todosLosUsuarios) {
            try {
              final personaResult = await _personasRepository
                  .getPersonaByIdentificacion(usuario.identificacion);
              await personaResult.fold(
                (failure) => null,
                (persona) {
                  _todosLosEmpleados.add(EmpleadoModel(
                    usuario: usuario,
                    persona: persona,
                    roles: [], // No cargamos roles aquí
                  ));
                },
              );
            } catch (e) {
              // Ignorar errores individuales
            }
          }

          setState(() {});

          // Si hay fechas seleccionadas, cargar estadísticas de ventas
          if (_fechaInicio != null && _fechaHasta != null) {
            await _cargarEstadisticasVentas();
          } else {
            if (mounted) {
              ref.read(appStateProvider.notifier).setLoading(false);
            }
          }
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

  // Cargar estadísticas de ventas para el rango de fechas seleccionado
  Future<void> _cargarEstadisticasVentas() async {
    if (_sucursalSeleccionada == null) {
      return;
    }

    if (_fechaInicio == null || _fechaHasta == null) {
      // Si no hay fechas, limpiar estadísticas pero mantener empleados
      setState(() {
        _empleadosStats = [];
        _totalVentasGeneral = 0;
        _montoTotalGeneral = 0.0;
      });
      if (mounted) {
        ref.read(appStateProvider.notifier).setLoading(false);
      }
      return;
    }

    final diferencia = _fechaHasta!.difference(_fechaInicio!);
    if (diferencia.inDays > MAX_DIAS) {
      DialogHelper.error(context,
          message: 'El rango máximo es de $MAX_DIAS días', onConfirmed: () {});
      if (mounted) {
        ref.read(appStateProvider.notifier).setLoading(false);
      }
      return;
    }

    try {
      // 1. Obtener mesas de la sucursal
      final mesasResult = await _mesaRepository.getMesasBySucursal(
        _sucursalSeleccionada!.idSucursal ?? 0,
      );

      await mesasResult.fold(
        (failure) async {
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

              // 3. Calcular estadísticas para cada empleado
              _empleadosStats.clear();

              // Crear un mapa de estadísticas por empleado
              final statsPorEmpleado = <int, Map<String, dynamic>>{};

              for (final venta in ventasFiltradas) {
                if (!statsPorEmpleado.containsKey(venta.idEmpleado)) {
                  statsPorEmpleado[venta.idEmpleado] = {
                    'totalVentas': 0,
                    'montoTotal': 0.0,
                  };
                }
                final stats = statsPorEmpleado[venta.idEmpleado]!;
                stats['totalVentas'] = (stats['totalVentas'] as int) + 1;
                if (venta.total != null) {
                  stats['montoTotal'] =
                      (stats['montoTotal'] as double) + venta.total!;
                }
              }

              // 4. Crear EmpleadoVentasStats para cada empleado
              for (final empleado in _todosLosEmpleados) {
                final idEmpleado = empleado.usuario?.idUsuario;
                if (idEmpleado == null) continue;

                final stats = statsPorEmpleado[idEmpleado];
                final totalVentas = stats?['totalVentas'] ?? 0;
                final montoTotal = stats?['montoTotal'] ?? 0.0;
                final promedioVenta =
                    totalVentas > 0 ? montoTotal / totalVentas : 0.0;

                _empleadosStats.add(EmpleadoVentasStats(
                  idEmpleado: idEmpleado,
                  nombre:
                      '${empleado.persona.nombres} ${empleado.persona.apellidos}',
                  identificacion: empleado.persona.identificacion,
                  totalVentas: totalVentas,
                  montoTotal: montoTotal,
                  promedioVenta: promedioVenta,
                  empleadoModel: empleado,
                ));
              }

              // Ordenar por número de ventas descendente
              _empleadosStats
                  .sort((a, b) => b.totalVentas.compareTo(a.totalVentas));

              // Calcular totales generales
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
                _todosLosEmpleados = [];
                _empleadosStats = [];
              });
              _cargarEmpleados();
            },
          ),
          const SizedBox(height: 16),
          DateRangeWidget(
            title: 'Rango de Fechas (opcional, máx. $MAX_DIAS días)',
            startDate: _fechaInicio,
            endDate: _fechaHasta,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
            onDateRangeSelected: (desde, hasta) {
              setState(() {
                if (desde != null && hasta != null) {
                  final diferencia = hasta.difference(desde);
                  final diasDiferencia = diferencia.inDays;
                  if (diasDiferencia > MAX_DIAS) {
                    _fechaHasta = desde.add(Duration(days: MAX_DIAS));
                    if (_fechaHasta != null &&
                        _fechaHasta!.isAfter(DateTime.now())) {
                      _fechaHasta = DateTime.now();
                    }
                    DialogHelper.info(context,
                        message: 'El rango máximo es de $MAX_DIAS días',
                        onConfirmed: () {});
                  } else {
                    _fechaInicio = desde;
                    _fechaHasta = hasta;
                  }
                  if (_fechaHasta != null &&
                      _fechaHasta!.isAfter(DateTime.now())) {
                    _fechaHasta = DateTime.now();
                  }
                } else {
                  _fechaInicio = desde;
                  _fechaHasta = hasta;
                }
              });
              // Cargar estadísticas cuando se seleccionan fechas
              if (_sucursalSeleccionada != null) {
                _cargarEstadisticasVentas();
              }
            },
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
              _buildListaEmpleados(),
            ],
          );
  }

  Widget _buildEstadisticas() {
    final promedioGeneral = _totalVentasGeneral > 0
        ? _montoTotalGeneral / _totalVentasGeneral
        : 0.0;

    return EstadisticasBasicasWidget(
      titulo: 'Resumen General',
      icono: Icons.analytics,
      estadisticas: [
        EstadisticaBasica(
          titulo: 'Total Empleados',
          valor: '$_totalEmpleados',
          icon: Icons.people,
          color: Colors.blue,
        ),
        EstadisticaBasica(
          titulo: 'Total Ventas',
          valor: '$_totalVentasGeneral',
          icon: Icons.point_of_sale,
          color: ThemeApp.primary,
        ),
        EstadisticaBasica(
          titulo: 'Monto Total',
          valor: '\$${_montoTotalGeneral.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        EstadisticaBasica(
          titulo: 'Promedio General',
          valor: '\$${promedioGeneral.toStringAsFixed(2)}',
          icon: Icons.trending_flat,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildListaEmpleados() {
    if (_todosLosEmpleados.isEmpty) {
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
              'Seleccione una sucursal para ver los empleados',
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

    // Si hay fechas seleccionadas, mostrar solo empleados con ventas
    // Si no hay fechas, mostrar todos los empleados
    final empleadosAMostrar = _fechaInicio != null && _fechaHasta != null
        ? _empleadosStats
        : _todosLosEmpleados
            .map((e) => EmpleadoVentasStats(
                  idEmpleado: e.usuario?.idUsuario ?? 0,
                  nombre: '${e.persona.nombres} ${e.persona.apellidos}',
                  identificacion: e.persona.identificacion,
                  totalVentas: 0,
                  montoTotal: 0.0,
                  promedioVenta: 0.0,
                  empleadoModel: e,
                ))
            .toList();

    if (empleadosAMostrar.isEmpty) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
          child: Row(
            children: [
              const Icon(Icons.people, color: ThemeApp.primary, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Empleados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.textPrimary,
                  ),
                ),
              ),
              if (_fechaInicio != null && _fechaHasta != null)
                Text(
                  '(${empleadosAMostrar.length} con ventas)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ThemeApp.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...empleadosAMostrar.map((stats) => _buildEmpleadoCard(stats)),
      ],
    );
  }

  Widget _buildEmpleadoCard(EmpleadoVentasStats stats) {
    final tieneVentas = stats.totalVentas > 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: ThemeApp.primary,
                  child: Text(
                    stats.nombre.isNotEmpty
                        ? stats.nombre[0].toUpperCase()
                        : 'E',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeApp.textPrimary,
                        ),
                      ),
                      if (stats.identificacion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          stats.identificacion,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeApp.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (tieneVentas) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildStatRow('Total Ventas', '${stats.totalVentas}'),
              _buildStatRow(
                  'Monto Total', '\$${stats.montoTotal.toStringAsFixed(2)}'),
              _buildStatRow('Promedio por Venta',
                  '\$${stats.promedioVenta.toStringAsFixed(2)}'),
            ] else if (_fechaInicio != null && _fechaHasta != null) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              const Text(
                'Sin ventas en el período seleccionado',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeApp.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (stats.empleadoModel != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EmpleadoEstadisticasPage(
                          empleado: stats.empleadoModel!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Ver Detalles'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeApp.primary,
                    side: const BorderSide(color: ThemeApp.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              fontWeight: FontWeight.w600,
              color: ThemeApp.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
