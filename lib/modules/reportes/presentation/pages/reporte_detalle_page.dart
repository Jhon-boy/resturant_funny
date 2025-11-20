import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';

enum TipoReporte {
  totalUsuarios,
  totalProductos,
  totalInventario,
  totalVentasGeneral,
  ventasPorEmpleado,
  usuariosRegistrados,
  inventario,
  empleados,
  resumenComparativas,
  sucursalesYMesas,
}

class ReporteDetallePage extends ConsumerStatefulWidget {
  final TipoReporte tipoReporte;
  final SucursalEntity? sucursal;
  final DateTime? fechaInicio;
  final DateTime? fechaHasta;

  const ReporteDetallePage({
    super.key,
    required this.tipoReporte,
    this.sucursal,
    this.fechaInicio,
    this.fechaHasta,
  });

  @override
  ConsumerState<ReporteDetallePage> createState() => _ReporteDetallePageState();
}

class _ReporteDetallePageState extends ConsumerState<ReporteDetallePage> {
  bool _isLoading = false;

  String get _titulo {
    switch (widget.tipoReporte) {
      case TipoReporte.totalUsuarios:
        return 'Total de Usuarios';
      case TipoReporte.totalProductos:
        return 'Total de Productos';
      case TipoReporte.totalInventario:
        return 'Total de Inventario';
      case TipoReporte.totalVentasGeneral:
        return 'Total Ventas General';
      case TipoReporte.ventasPorEmpleado:
        return 'Ventas por Empleado';
      case TipoReporte.usuariosRegistrados:
        return 'Usuarios Registrados';
      case TipoReporte.inventario:
        return 'Inventario';
      case TipoReporte.empleados:
        return 'Empleados';
      case TipoReporte.resumenComparativas:
        return 'Resumen Comparativas';
      case TipoReporte.sucursalesYMesas:
        return 'Sucursales y Mesas';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    // TODO: Cargar datos del reporte desde la BD
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _generarPDF() async {
    // TODO: Implementar generación de PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando PDF...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: _titulo,
      onBack: () => Navigator.of(context).pop(),
      actions: IconButton(
        icon: const Icon(Icons.picture_as_pdf),
        onPressed: _generarPDF,
        tooltip: 'Generar PDF',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del filtro
                  if (widget.sucursal != null)
                    _buildInfoCard(
                      'Sucursal',
                      widget.sucursal!.nombre,
                      Icons.store,
                    ),
                  if (widget.fechaInicio != null && widget.fechaHasta != null)
                    _buildInfoCard(
                      'Período',
                      '${_formatearFecha(widget.fechaInicio!)} - ${_formatearFecha(widget.fechaHasta!)}',
                      Icons.calendar_today,
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

  Widget _buildInfoCard(String titulo, String valor, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeApp.baseText,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: ThemeApp.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeApp.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeApp.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoReporte() {
    // TODO: Implementar contenido específico de cada reporte
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeApp.baseText,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assessment,
            size: 64,
            color: ThemeApp.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Contenido del reporte: $_titulo',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeApp.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Aquí se mostrarán los datos del reporte',
            style: TextStyle(
              fontSize: 14,
              color: ThemeApp.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}
