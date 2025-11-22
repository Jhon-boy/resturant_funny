import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/reportes/domain/models/producto_venta_stats.dart';
import 'package:resturant_funny/modules/reportes/domain/services/estadisticas_productos_service.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadisticas_basicas_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/reporte_data_table_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/detalles_ventas_datasource.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/detalles_venta_impl.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/detalle_venta_repository.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/not_found_card.dart';

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
  late DetalleVentaRepository _detalleVentaRepository;
  late VentaRepository _ventaRepository;
  late MesaRepository _mesaRepository;

  // Filtros
  SucursalEntity? _sucursalSeleccionada;
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  // Datos
  List<ProductoEntity> _productos = [];
  EstadisticasProductos? _estadisticas;

  // Estadísticas básicas de productos
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
      _detalleVentaRepository = DetalleVentaRepositoryImpl(
        DetalleVentaRemoteDataSource(ref: ref),
      );
      _ventaRepository = VentaRepositoryImpl(
        VentasRemoteDataSource(ref: ref),
      );
      _mesaRepository = MesaRepositoryImpl(
        MesasRemoteDataSource(ref: ref),
      );

      final ahora = DateTime.now();
      _fechaHasta = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);
      _fechaDesde = _fechaHasta!.subtract(const Duration(days: 30));

      // Seleccionar primera sucursal por defecto si existe
      if (widget.sucursales.isNotEmpty) {
        _sucursalSeleccionada = widget.sucursales.first;
        SnackHelper.show(context,
            message: 'Seleccionando sucursal', isSuccess: true);
        _cargarDatos();
      }
    });
  }

  Future<void> _cargarDatos() async {
    if (_sucursalSeleccionada == null) {
      setState(() {
        _productos = [];
        _estadisticas = null;
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
      // Cargar productos
      final productosResult = await _productosRepository.getProductos(
        _sucursalSeleccionada!.idSucursal ?? 0,
      );

      await productosResult.fold(
        (failure) async {
          DialogHelper.error(context,
              message: failure.message, onConfirmed: () {});
          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        (productos) async {
          // Calcular estadísticas básicas
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

          // Cargar estadísticas de productos vendidos
          try {
            // 1. Obtener mesas de la sucursal
            final mesasResult = await _mesaRepository.getMesasBySucursal(
              _sucursalSeleccionada!.idSucursal ?? 0,
            );

            await mesasResult.fold(
              (failure) async {
                _estadisticas = null;
              },
              (mesas) async {
                if (mesas.isEmpty) {
                  _estadisticas = null;
                  return;
                }

                final idsMesas = mesas.map((m) => m.idMesa ?? 0).toList();

                // 2. Obtener ventas de esas mesas
                final ventasResult = await _ventaRepository.getVentas(
                  fechaDesde: _fechaDesde,
                  fechaHasta: _fechaHasta?.add(const Duration(days: 1)),
                );

                await ventasResult.fold(
                  (failure) async {
                    _estadisticas = null;
                  },
                  (ventas) async {
                    // Filtrar ventas por mesas de la sucursal
                    final ventasFiltradas = ventas
                        .where((v) => idsMesas.contains(v.idMesa))
                        .toList();

                    final idsVentas =
                        ventasFiltradas.map((v) => v.idVenta!).toList();

                    if (idsVentas.isEmpty) {
                      _estadisticas = null;
                      return;
                    }

                    // 3. Obtener detalles con productos
                    final detallesResult = await _detalleVentaRepository
                        .getDetallesConProductosBySucursal(
                      idsVentas,
                      fechaDesde: _fechaDesde,
                      fechaHasta: _fechaHasta,
                    );

                    final detallesConProductos = detallesResult.fold(
                      (failure) => <Map<String, dynamic>>[],
                      (detalles) => detalles,
                    );

                    if (detallesConProductos.isNotEmpty) {
                      _estadisticas =
                          EstadisticasProductosService.calcularEstadisticas(
                        detallesConProductos,
                      );
                    } else {
                      _estadisticas = null;
                    }
                  },
                );
              },
            );
          } catch (e) {
            _estadisticas = null;
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
            _buildFiltros(),
            const SizedBox(height: 24),
            _buildContenidoReporte(),
            const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          DateRangeWidget(
            title: 'Rango de Fechas (para estadísticas de ventas)',
            startDate: _fechaDesde,
            endDate: _fechaHasta,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onDateRangeSelected: (desde, hasta) {
              setState(() {
                _fechaDesde = desde;
                _fechaHasta = hasta;
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
              if (_estadisticas != null) ...[
                _buildEstadisticasVentas(),
                const SizedBox(height: 24),
              ],
              _buildEstadisticasBasicas(),
              const SizedBox(height: 24),
              _buildListaProductos(),
            ],
          );
  }

  Widget _buildEstadisticasVentas() {
    final stats = _estadisticas!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeApp.primary.withOpacity(0.8),
                ThemeApp.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ThemeApp.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Estadísticas de Productos Vendidos',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Producto más vendido
        if (stats.productoMasVendido != null)
          _buildProductoMasVendidoCard(stats.productoMasVendido!),
        const SizedBox(height: 16),
        // Grid de estadísticas
        EstadisticasBasicasWidget(
          titulo: 'Estadísticas de Ventas',
          icono: Icons.analytics,
          estadisticas: [
            EstadisticaBasica(
              titulo: 'Total Unidades Vendidas',
              valor: '${stats.totalUnidadesVendidas}',
              icon: Icons.shopping_cart,
              color: Colors.blue,
            ),
            EstadisticaBasica(
              titulo: 'Total Ingresos',
              valor: '\$${stats.totalIngresosProductos.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            EstadisticaBasica(
              titulo: 'Productos Diferentes',
              valor: '${stats.totalProductosDiferentes}',
              icon: Icons.inventory_2,
              color: Colors.orange,
            ),
            if (stats.categoriaMasConsumida != null)
              EstadisticaBasica(
                titulo: 'Categoría Más Consumida',
                valor: stats.categoriaMasConsumida!.categoria,
                icon: Icons.category,
                color: Colors.purple,
              ),
          ],
        ),
        // Top productos
        if (stats.topProductos.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTopProductos(stats.topProductos),
        ],
      ],
    );
  }

  Widget _buildProductoMasVendidoCard(ProductoVentaStats producto) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star, color: Colors.amber, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Producto Más Vendido',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  producto.producto.nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${producto.totalCantidadVendida} unidades vendidas • \$${producto.totalIngresos.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ThemeApp.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductos(List<ProductoVentaStats> topProductos) {
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
              Icon(Icons.trending_up, color: ThemeApp.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Top 5 Productos Más Vendidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topProductos.asMap().entries.map((entry) {
            final index = entry.key;
            final producto = entry.value;
            return Container(
              margin: EdgeInsets.only(
                  bottom: index < topProductos.length - 1 ? 12 : 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeApp.baseText,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ThemeApp.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeApp.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.producto.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${producto.totalCantidadVendida} unidades • \$${producto.totalIngresos.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: ThemeApp.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEstadisticasBasicas() {
    return EstadisticasBasicasWidget(
      titulo: 'Estadísticas de Productos en Inventario',
      icono: Icons.info_outline,
      estadisticas: [
        EstadisticaBasica(
          titulo: 'Total Productos',
          valor: '$_totalProductos',
          icon: Icons.inventory_2,
          color: Colors.blue,
        ),
        EstadisticaBasica(
          titulo: 'Precio Promedio',
          valor: '\$${_precioPromedio.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        EstadisticaBasica(
          titulo: 'Precio Máximo',
          valor: '\$${_precioMaximo.toStringAsFixed(2)}',
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
        EstadisticaBasica(
          titulo: 'Precio Mínimo',
          valor: '\$${_precioMinimo.toStringAsFixed(2)}',
          icon: Icons.trending_down,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildListaProductos() {
    if (_productos.isEmpty) {
      return const NotFoundCard(
          message: 'No se encontraron productos',
          icon: Icons.inventory_2_outlined);
    }

    return ReporteDataTableWidget(
      titulo: 'Listado Completo de Productos',
      icono: Icons.table_chart,
      mensajeVacio: 'No se encontraron productos',
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
            DataCell(
              Tooltip(
                message: producto.nombre,
                child: Text(
                  producto.nombre,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            DataCell(
              Tooltip(
                message: producto.descripcion,
                child: SizedBox(
                  width: 150,
                  child: Text(
                    producto.descripcion,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ),
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
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: producto.estado == 'ACT'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  producto.estado ?? 'N/A',
                  style: TextStyle(
                    color:
                        producto.estado == 'ACT' ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
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
