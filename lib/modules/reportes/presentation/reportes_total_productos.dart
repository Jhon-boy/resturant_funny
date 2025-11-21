import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadistica_card_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/reporte_data_table_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class ReporteTotalProductosPage extends ConsumerStatefulWidget {
  const ReporteTotalProductosPage({super.key, required this.sucursales});
  final List<SucursalEntity> sucursales;

  @override
  ConsumerState<ReporteTotalProductosPage> createState() =>
      _ReporteTotalProductosPageState();
}

class _ReporteTotalProductosPageState
    extends ConsumerState<ReporteTotalProductosPage> {
  late ProductosRepository _productosRepository;

  // Filtros
  SucursalEntity? _sucursalSeleccionada;

  List<ProductoEntity> _productos = [];
  int _totalProductos = 0;
  double _precioPromedio = 0.0;
  double _precioMaximo = 0.0;
  double _precioMinimo = 0.0;
  final Map<String, int> _productosPorCategoria = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productosRepository = ProductosRepositoryImpl(
        ProductosRemoteDataSource(ref: ref),
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
        _productos = [];
        _totalProductos = 0;
        _precioPromedio = 0.0;
        _precioMaximo = 0.0;
        _precioMinimo = 0.0;
        _productosPorCategoria.clear();
      });
      return;
    }

    ref.read(appStateProvider.notifier).setLoading(true);

    try {
      final productosResult = await _productosRepository.getProductos(
        _sucursalSeleccionada!.idSucursal ?? 0,
      );

      productosResult.fold(
        (failure) {
          DialogHelper.error(context,
              message: failure.message, onConfirmed: () {});
          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        (productos) {
          // Calcular estadísticas
          _totalProductos = productos.length;

          if (productos.isNotEmpty) {
            final precios = productos.map((p) => p.precio).toList();
            _precioPromedio = precios.reduce((a, b) => a + b) / precios.length;
            _precioMaximo = precios.reduce((a, b) => a > b ? a : b);
            _precioMinimo = precios.reduce((a, b) => a < b ? a : b);
          } else {
            _precioPromedio = 0.0;
            _precioMaximo = 0.0;
            _precioMinimo = 0.0;
          }

          // Productos por categoría
          _productosPorCategoria.clear();
          for (final producto in productos) {
            _productosPorCategoria[producto.categoria] =
                (_productosPorCategoria[producto.categoria] ?? 0) + 1;
          }

          setState(() {
            _productos = productos;
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
      title: 'Total de Productos',
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
              _buildListaProductos(),
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
                'Estadísticas',
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
                titulo: 'Total Productos',
                icon: Icons.restaurant_menu,
                color: Colors.orange,
                valor: '$_totalProductos',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Precio Promedio',
                icon: Icons.attach_money,
                color: Colors.blue,
                valor: '\$${_precioPromedio.toStringAsFixed(2)}',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Precio Máximo',
                icon: Icons.trending_up,
                color: Colors.purple,
                valor: '\$${_precioMaximo.toStringAsFixed(2)}',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Precio Mínimo',
                icon: Icons.trending_down,
                color: Colors.teal,
                valor: '\$${_precioMinimo.toStringAsFixed(2)}',
                onTap: () {},
              ),
            ],
          ),
          if (_productosPorCategoria.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Productos por Categoría',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeApp.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._productosPorCategoria.entries.map((entry) {
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
                      '${entry.value} producto${entry.value > 1 ? 's' : ''}',
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

  Widget _buildListaProductos() {
    if (_productos.isEmpty) {
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
              'No se encontraron productos en el período seleccionado',
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
      titulo: 'Tabla de Productos',
      icono: Icons.table_chart,
      mensajeVacio: 'No se encontraron productos en el período seleccionado',
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
            'Categoría',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Precio',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Disponible',
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
            'Fecha Creación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: _productos.map((producto) {
        return DataRow(
          cells: [
            DataCell(Text('${producto.idProducto ?? 'N/A'}')),
            DataCell(Text(producto.nombre)),
            DataCell(Text(producto.categoria)),
            DataCell(Text('\$${producto.precio.toStringAsFixed(2)}')),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    producto.disponible == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 16,
                    color:
                        producto.disponible == true ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    producto.disponible == true ? 'Sí' : 'No',
                    style: TextStyle(
                      color: producto.disponible == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(Text(producto.estado ?? 'N/A')),
            DataCell(Text(
              producto.fCreacion != null
                  ? AppUtils.formatDate(producto.fCreacion)
                  : 'N/A',
            )),
          ],
        );
      }).toList(),
    );
  }
}
