import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadistica_card_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_total_usuario.dart';
import 'package:resturant_funny/shared/enums/tipo_reportes.dart';

class ReportesPage extends ConsumerStatefulWidget {
  const ReportesPage({super.key, required this.titulo});
  final String titulo;

  @override
  ConsumerState<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends ConsumerState<ReportesPage> {
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
            _buildSectionTitle('General'),
            const SizedBox(height: 12),
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
            const SizedBox(height: 32),

            // SECCIÓN: ESTADÍSTICAS
            _buildSectionTitle('Estadísticas'),
            const SizedBox(height: 12),
            EstadisticaCardWidget(
              titulo: 'Total Ventas General',
              icon: Icons.point_of_sale,
              color: ThemeApp.primary,
              valor: '0',
              onTap: () => _navegarAReporte(TipoReporte.totalVentasGeneral),
            ),
            const SizedBox(height: 12),
            EstadisticaCardWidget(
              titulo: 'Ventas por Empleado',
              icon: Icons.person_outline,
              color: Colors.teal,
              valor: '0',
              onTap: () => _navegarAReporte(TipoReporte.ventasPorEmpleado),
            ),
            const SizedBox(height: 12),
            EstadisticaCardWidget(
              titulo: 'Usuarios Registrados',
              icon: Icons.person_add,
              color: Colors.green,
              valor: '0',
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
            builder: (context) => const ReporteTotalUsuariosPage(),
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
