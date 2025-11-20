import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadistica_card_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/filtros_reportes_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/pages/reporte_detalle_page.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';

class ReportesPage extends ConsumerStatefulWidget {
  const ReportesPage({super.key, required this.titulo});
  final String titulo;

  @override
  ConsumerState<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends ConsumerState<ReportesPage> {
  SucursalEntity? _sucursalSeleccionada;
  DateTime? _fechaInicio;
  DateTime? _fechaHasta;
  List<SucursalEntity> _sucursales = [];
  bool _cargandoSucursales = false;
  late SucursalRepository _sucursalRepository;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sucursalRepository = SucursalRemoteRepository(
        SucursalRemoteDataSource(ref: ref),
      );
      _cargarSucursales();
    });
  }

  Future<void> _cargarSucursales() async {
    setState(() => _cargandoSucursales = true);
    final result = await _sucursalRepository.getSucursalesEntity();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        }
      },
      (sucursales) {
        if (mounted) {
          setState(() {
            _sucursales = sucursales.where((s) => s.isActiva).toList();
            if (_sucursales.isNotEmpty && _sucursalSeleccionada == null) {
              _sucursalSeleccionada = _sucursales.first;
            }
          });
        }
      },
    );
    setState(() => _cargandoSucursales = false);
  }

  void _onFechasChanged(DateTime? fechaInicio, DateTime? fechaHasta) {
    setState(() {
      _fechaInicio = fechaInicio;
      _fechaHasta = fechaHasta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      onBack: () => Navigator.of(context).pop(),
      title: widget.titulo,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FiltrosReportesWidget(
              sucursalSeleccionada: _sucursalSeleccionada,
              sucursales: _sucursales,
              fechaInicio: _fechaInicio,
              fechaHasta: _fechaHasta,
              onSucursalChanged: (sucursal) {
                setState(() => _sucursalSeleccionada = sucursal);
              },
              onFechasChanged: _onFechasChanged,
              cargando: _cargandoSucursales,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('General'),
            const SizedBox(height: 12),
            if (_sucursalSeleccionada != null) ...[
              EstadisticaCardWidget(
                titulo: 'Total Usuarios',
                icon: Icons.people_outline,
                color: Colors.blue,
                valor: '0',
                onTap: () => _navegarAReporte(TipoReporte.totalUsuarios),
              ),
              const SizedBox(height: 12),
              EstadisticaCardWidget(
                titulo: 'Total Productos',
                icon: Icons.restaurant_menu,
                color: Colors.orange,
                valor: '0',
                onTap: () => _navegarAReporte(TipoReporte.totalProductos),
              ),
              const SizedBox(height: 12),
              EstadisticaCardWidget(
                titulo: 'Total Inventario',
                icon: Icons.inventory_2_outlined,
                color: Colors.purple,
                valor: '0',
                onTap: () => _navegarAReporte(TipoReporte.totalInventario),
              ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Seleccione una sucursal para ver los reportes'),
                ),
              ),
            const SizedBox(height: 32),

            // SECCIÓN: ESTADÍSTICAS
            _buildSectionTitle('Estadísticas'),
            const SizedBox(height: 12),
            if (_sucursalSeleccionada != null) ...[
              EstadisticaCardWidget(
                titulo: 'Total Ventas General',
                icon: Icons.point_of_sale,
                color: ThemeApp.primary,
                valor: '0',
                subtitulo: _fechaInicio != null && _fechaHasta != null
                    ? '${_fechaInicio!.toString().split(' ')[0]} - ${_fechaHasta!.toString().split(' ')[0]}'
                    : 'Seleccione rango de fechas',
                onTap: () => _navegarAReporte(TipoReporte.totalVentasGeneral),
              ),
              const SizedBox(height: 12),
              EstadisticaCardWidget(
                titulo: 'Ventas por Empleado',
                icon: Icons.person_outline,
                color: Colors.teal,
                valor: '0',
                subtitulo: _fechaInicio != null &&
                        _fechaHasta != null &&
                        _fechaHasta!.difference(_fechaInicio!).inDays == 3
                    ? 'Comparativa de 3 días'
                    : 'Seleccione rango de 3 días',
                onTap: () => _navegarAReporteEmpleado(),
              ),
              const SizedBox(height: 12),
              EstadisticaCardWidget(
                titulo: 'Usuarios Registrados',
                icon: Icons.person_add,
                color: Colors.green,
                valor: '0',
                subtitulo: _fechaInicio != null &&
                        _fechaHasta != null &&
                        _fechaHasta!.difference(_fechaInicio!).inDays == 3
                    ? 'En el rango de 3 días seleccionado'
                    : 'Seleccione rango de 3 días',
                onTap: () => _navegarAReporte(TipoReporte.usuariosRegistrados),
              ),
              const SizedBox(height: 12),
              EstadisticaCardWidget(
                titulo: 'Inventario',
                icon: Icons.inventory,
                color: Colors.indigo,
                valor: '0',
                onTap: () => _navegarAReporte(TipoReporte.inventario),
              ),
              const SizedBox(height: 12),
              EstadisticaCardWidget(
                titulo: 'Empleados',
                icon: Icons.people,
                color: Colors.cyan,
                valor: '0',
                onTap: () => _navegarAReporte(TipoReporte.empleados),
              ),
              const SizedBox(height: 12),
              EstadisticaCardWidget(
                titulo: 'Resumen Comparativas',
                icon: Icons.compare_arrows,
                color: Colors.pink,
                valor: 'Ver',
                onTap: () => _navegarAReporte(TipoReporte.resumenComparativas),
              ),
              const SizedBox(height: 12),
              EstadisticaCardWidget(
                titulo: 'Sucursales y Mesas',
                icon: Icons.store,
                color: Colors.amber,
                valor: 'Ver',
                subtitulo: 'Mesas por sucursal',
                onTap: () => _navegarAReporte(TipoReporte.sucursalesYMesas),
              ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child:
                      Text('Seleccione una sucursal para ver las estadísticas'),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: ThemeApp.textPrimary,
      ),
    );
  }

  void _navegarAReporte(TipoReporte tipoReporte) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReporteDetallePage(
          tipoReporte: tipoReporte,
          sucursal: _sucursalSeleccionada,
          fechaInicio: _fechaInicio,
          fechaHasta: _fechaHasta,
        ),
      ),
    );
  }

  void _navegarAReporteEmpleado() {
    if (_fechaInicio == null || _fechaHasta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione rango de fechas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final diferencia = _fechaHasta!.difference(_fechaInicio!).inDays;
    if (diferencia != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'El rango debe ser exactamente de 3 días (actual: $diferencia días)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _navegarAReporte(TipoReporte.ventasPorEmpleado);
  }
}
