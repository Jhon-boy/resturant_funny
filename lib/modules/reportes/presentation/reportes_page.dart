import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadistica_card_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_total_usuario.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_total_productos.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_total_inventario.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_total_ventas.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_ventas_por_empleado.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_sucursales_mesas.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_resumen_comparativas.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/resumen_ventas_widget.dart';
import 'package:resturant_funny/shared/enums/tipo_reportes.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class ReportesPage extends ConsumerStatefulWidget {
  const ReportesPage({super.key, required this.titulo});
  final String titulo;

  @override
  ConsumerState<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends ConsumerState<ReportesPage> {
  late SucursalRepository _sucursalRepository;
  bool _loading = false;
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

  List<SucursalEntity> _sucursales = [];
  Future<void> _cargarSucursales() async {
    setState(() => _loading = true);
    final result = await _sucursalRepository.getSucursalesEntity();
    result.fold(
      (failure) {
        setState(() => _loading = false);
        if (mounted) {
          DialogHelper.error(context, message: failure.message,
              onConfirmed: () {
            Navigator.of(context).pop();
          });
        }
      },
      (sucursales) {
        setState(() => _loading = false);
        if (mounted) {
          setState(() {
            _sucursales = sucursales.where((s) => s.isActiva).toList();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      onBack: () => Navigator.of(context).pop(),
      title: widget.titulo,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? Center(child: ShimmerWidget.list(itemCount: 3))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen de Ventas (lo primero que ve el administrador)
                  const ResumenVentasWidget(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('General'),
                  const SizedBox(height: 12),
                  EstadisticaCardWidget(
                    titulo: 'Usuarios Registrados',
                    icon: Icons.people_outline,
                    color: Colors.blue,
                    valor: '0',
                    subtitulo: 'Usuarios registrados en el sistema',
                    onTap: () => _navegarAReporte(TipoReporte.totalUsuarios),
                  ),
                  const SizedBox(height: 12),
                  EstadisticaCardWidget(
                    titulo: 'Productos Disponibles',
                    icon: Icons.restaurant_menu,
                    color: Colors.orange,
                    valor: '0',
                    subtitulo: 'Productos disponibles en el sistema',
                    onTap: () => _navegarAReporte(TipoReporte.totalProductos),
                  ),
                  const SizedBox(height: 12),
                  EstadisticaCardWidget(
                    titulo: 'Total Inventario',
                    icon: Icons.inventory_2_outlined,
                    color: Colors.purple,
                    valor: '0',
                    subtitulo: 'Inventario de productos en el sistema',
                    onTap: () => _navegarAReporte(TipoReporte.totalInventario),
                  ),
                  const SizedBox(height: 32),

                  // SECCIÓN: ESTADÍSTICAS
                  _buildSectionTitle('Estadísticas'),
                  const SizedBox(height: 12),
                  EstadisticaCardWidget(
                    titulo: 'Total Ventas General',
                    icon: Icons.point_of_sale,
                    color: ThemeApp.primary,
                    valor: '0',
                    subtitulo: 'Ventas generales en el sistema',
                    onTap: () =>
                        _navegarAReporte(TipoReporte.totalVentasGeneral),
                  ),
                  const SizedBox(height: 12),
                  EstadisticaCardWidget(
                    titulo: 'Ventas por Empleado',
                    icon: Icons.person_outline,
                    color: Colors.teal,
                    valor: '0',
                    subtitulo: 'Ventas por empleado en el sistema',
                    onTap: () =>
                        _navegarAReporte(TipoReporte.ventasPorEmpleado),
                  ),
                  const SizedBox(height: 12),
                  EstadisticaCardWidget(
                    titulo: 'Resumen Comparativas',
                    icon: Icons.compare_arrows,
                    color: Colors.pink,
                    valor: 'Ver',
                    subtitulo: 'Resumen comparativo de ventas',
                    onTap: () =>
                        _navegarAReporte(TipoReporte.resumenComparativas),
                  ),
                  const SizedBox(height: 12),
                  EstadisticaCardWidget(
                    titulo: 'Sucursales y Mesas',
                    icon: Icons.store,
                    color: Colors.amber,
                    valor: 'Ver',
                    subtitulo: 'Mesas y sucursales en el sistema',
                    onTap: () => _navegarAReporte(TipoReporte.sucursalesYMesas),
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
    switch (tipoReporte) {
      case TipoReporte.totalUsuarios:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ReporteTotalUsuariosPage(sucursales: _sucursales),
          ),
        );
        break;
      case TipoReporte.totalProductos:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ReporteTotalProductosPage(sucursales: _sucursales),
          ),
        );
        break;
      case TipoReporte.totalInventario:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ReporteTotalInventarioPage(sucursales: _sucursales),
          ),
        );
        break;
      case TipoReporte.totalVentasGeneral:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ReporteTotalVentasPage(sucursales: _sucursales),
          ),
        );
        break;
      case TipoReporte.ventasPorEmpleado:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ReporteVentasPorEmpleadoPage(sucursales: _sucursales),
          ),
        );
        break;
      case TipoReporte.sucursalesYMesas:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ReporteSucursalesMesasPage(),
          ),
        );
        break;
      case TipoReporte.resumenComparativas:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ReporteResumenComparativasPage(),
          ),
        );
        break;
      default:
        SnackHelper.show(
          context,
          message: 'Reporte en desarrollo',
          isError: true,
        );
        break;
    }
  }
}
