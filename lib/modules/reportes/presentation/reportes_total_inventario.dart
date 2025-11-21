// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/inventario/data/datasource/inventario_data_source.dart';
import 'package:resturant_funny/modules/inventario/data/repository/inventario_repository_impl.dart';
import 'package:resturant_funny/modules/inventario/domain/repository/inventario_repository.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadistica_card_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/reporte_data_table_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class ReporteTotalInventarioPage extends ConsumerStatefulWidget {
  const ReporteTotalInventarioPage({super.key, required this.sucursales});
  final List<SucursalEntity> sucursales;

  @override
  ConsumerState<ReporteTotalInventarioPage> createState() =>
      _ReporteTotalInventarioPageState();
}

class _ReporteTotalInventarioPageState
    extends ConsumerState<ReporteTotalInventarioPage> {
  late InventarioRepository _inventarioRepository;

  // Filtros
  SucursalEntity? _sucursalSeleccionada;

  List<InventarioEntity> _inventarios = [];
  int _totalItems = 0;
  int _stockTotal = 0;
  double _valorTotalInventario = 0.0;
  double _precioPromedio = 0.0;
  final Map<String, int> _inventarioPorCategoria = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inventarioRepository = InventarioRepositoryImpl(
        InventarioRemoteDataSource(ref: ref),
      );
      // Seleccionar primera sucursal por defecto si existe
      if (widget.sucursales.isNotEmpty) {
        _sucursalSeleccionada = widget.sucursales.first;
        _cargarDatos();
      }
    });
  }

  Future<void> _cargarDatos() async {
    if (_sucursalSeleccionada == null) {
      setState(() {
        _inventarios = [];
        _totalItems = 0;
        _stockTotal = 0;
        _valorTotalInventario = 0.0;
        _precioPromedio = 0.0;
        _inventarioPorCategoria.clear();
      });
      return;
    }

    ref.read(appStateProvider.notifier).setLoading(true);

    try {
      final inventariosResult =
          await _inventarioRepository.getInventarioBySucursal(
        _sucursalSeleccionada!.idSucursal ?? 0,
      );

      inventariosResult.fold(
        (failure) {
          DialogHelper.error(context,
              message: failure.message, onConfirmed: () {});
          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        (inventarios) {
          // Calcular estadísticas
          _totalItems = inventarios.length;

          // Calcular stock total y valor total
          int stockTotal = 0;
          double valorTotal = 0.0;
          List<double> precios = [];

          for (final inventario in inventarios) {
            final stock = inventario.stock ?? 0;
            stockTotal += stock;

            if (inventario.precioUnitario != null) {
              precios.add(inventario.precioUnitario!);
              valorTotal += stock * inventario.precioUnitario!;
            }
          }

          _stockTotal = stockTotal;
          _valorTotalInventario = valorTotal;
          _precioPromedio = precios.isNotEmpty
              ? precios.reduce((a, b) => a + b) / precios.length
              : 0.0;

          // Inventario por categoría
          _inventarioPorCategoria.clear();
          for (final inventario in inventarios) {
            final categoria = inventario.categoria ?? 'Sin categoría';
            _inventarioPorCategoria[categoria] =
                (_inventarioPorCategoria[categoria] ?? 0) + 1;
          }

          setState(() {
            _inventarios = inventarios;
          });

          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
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

  void _generarPDF() {
    DialogHelper.info(context,
        message: 'Generación de PDF próximamente', onConfirmed: () {});
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: 'Total de Inventario',
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
              _cargarDatos();
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
              _buildListaInventario(),
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
                'Resumen del Inventario',
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
                titulo: 'Total Items',
                icon: Icons.inventory_2_outlined,
                color: Colors.purple,
                valor: '$_totalItems',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Stock Total',
                icon: Icons.storage,
                color: Colors.blue,
                valor: '$_stockTotal unidades',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Valor Total',
                icon: Icons.attach_money,
                color: Colors.green,
                valor: '\$${_valorTotalInventario.toStringAsFixed(2)}',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Precio Promedio',
                icon: Icons.trending_flat,
                color: Colors.orange,
                valor: '\$${_precioPromedio.toStringAsFixed(2)}',
                onTap: () {},
              ),
            ],
          ),
          if (_inventarioPorCategoria.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Items por Categoría',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeApp.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._inventarioPorCategoria.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeApp.textSecondary,
                      ),
                    ),
                    Text(
                      '${entry.value} item${entry.value > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeApp.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildListaInventario() {
    if (_inventarios.isEmpty) {
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
              Icons.inventory_2_outlined,
              size: 64,
              color: ThemeApp.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No se encontró inventario en la sucursal seleccionada',
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
      titulo: 'Tabla de Inventario',
      icono: Icons.table_chart,
      mensajeVacio: 'No se encontró inventario en la sucursal seleccionada',
      columns: const [
        DataColumn(
          label: Text(
            'ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Nombre',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Descripción',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Categoría',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Stock',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Precio Unitario',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Valor Total',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Estado',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: _inventarios.map((inventario) {
        final valorTotal =
            (inventario.stock ?? 0) * (inventario.precioUnitario ?? 0.0);
        return DataRow(
          cells: [
            DataCell(Text('${inventario.idInventario ?? 'N/A'}')),
            DataCell(Text(inventario.nombre)),
            DataCell(Text(inventario.descripcion ?? 'N/A')),
            DataCell(Text(inventario.categoria ?? 'Sin categoría')),
            DataCell(Text('${inventario.stock ?? 0} unidades')),
            DataCell(Text(
              inventario.precioUnitario != null
                  ? '\$${inventario.precioUnitario!.toStringAsFixed(2)}'
                  : 'N/A',
            )),
            DataCell(Text(
              inventario.precioUnitario != null
                  ? '\$${valorTotal.toStringAsFixed(2)}'
                  : 'N/A',
            )),
            DataCell(Text(inventario.estado ?? 'N/A')),
          ],
        );
      }).toList(),
    );
  }
}
