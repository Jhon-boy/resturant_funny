// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/detalles_ventas_datasource.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/detalles_venta_impl.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/detalle_venta_repository.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadistica_card_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class ReporteTotalVentasPage extends ConsumerStatefulWidget {
  const ReporteTotalVentasPage({super.key, required this.sucursales});
  final List<SucursalEntity> sucursales;

  @override
  ConsumerState<ReporteTotalVentasPage> createState() =>
      _ReporteTotalVentasPageState();
}

class _ReporteTotalVentasPageState
    extends ConsumerState<ReporteTotalVentasPage> {
  late VentaRepository _ventaRepository;
  late DetalleVentaRepository _detalleVentaRepository;
  late MesaRepository _mesaRepository;
  late PersonasRemoteDataSource _personasDataSource;
  late UsuariosRemoteDataSource _usuariosDataSource;
  late ProductosRemoteDataSource _productosDataSource;

  // Filtros
  SucursalEntity? _sucursalSeleccionada;
  DateTime? _fechaInicio;
  DateTime? _fechaHasta;

  int _totalVentas = 0;
  double _montoTotalVendido = 0.0;
  double _promedioVenta = 0.0;
  final Map<int, int> _ventasPorEmpleado = {}; // idEmpleado -> cantidad
  final Map<int, String> _nombresEmpleados = {}; // idEmpleado -> nombre
  final Map<int, int> _productosVendidos = {}; // idProducto -> cantidad total
  final Map<int, String> _nombresProductos = {}; // idProducto -> nombre
  final Map<String, int> _ventasPorTipo = {}; // tipoVenta -> cantidad

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ventaRepository = VentaRepositoryImpl(
        VentasRemoteDataSource(ref: ref),
      );
      _detalleVentaRepository = DetalleVentaRepositoryImpl(
        DetalleVentaRemoteDataSource(ref: ref),
      );
      _mesaRepository = MesaRepositoryImpl(
        MesasRemoteDataSource(ref: ref),
      );
      _personasDataSource = PersonasRemoteDataSource(ref: ref);
      _usuariosDataSource = UsuariosRemoteDataSource(ref: ref);
      _productosDataSource = ProductosRemoteDataSource(ref: ref);
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
              _totalVentas = 0;
              _montoTotalVendido = 0.0;
              _promedioVenta = 0.0;
              _ventasPorEmpleado.clear();
              _nombresEmpleados.clear();
              _productosVendidos.clear();
              _nombresProductos.clear();
              _ventasPorTipo.clear();
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

          ventasResult.fold(
            (failure) {
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

              // 3. Calcular estadísticas básicas
              _totalVentas = ventasFiltradas.length;
              _montoTotalVendido = ventasFiltradas
                  .where((v) => v.total != null)
                  .map((v) => v.total!)
                  .fold(0.0, (a, b) => a + b);
              _promedioVenta =
                  _totalVentas > 0 ? _montoTotalVendido / _totalVentas : 0.0;

              // 4. Ventas por empleado
              _ventasPorEmpleado.clear();
              _nombresEmpleados.clear();
              final empleadosUnicos = <int>{};
              for (final venta in ventasFiltradas) {
                _ventasPorEmpleado[venta.idEmpleado] =
                    (_ventasPorEmpleado[venta.idEmpleado] ?? 0) + 1;
                empleadosUnicos.add(venta.idEmpleado);
              }

              // Obtener nombres de empleados
              for (final idEmpleado in empleadosUnicos) {
                try {
                  final usuarioResult =
                      await _usuariosDataSource.getUsuarioById(idEmpleado);
                  if (usuarioResult != null) {
                    final personaResult = await _personasDataSource
                        .getPersonaById(usuarioResult.identificacion);
                    if (personaResult != null) {
                      _nombresEmpleados[idEmpleado] =
                          '${personaResult.nombres} ${personaResult.apellidos}';
                    } else {
                      _nombresEmpleados[idEmpleado] = 'Empleado #$idEmpleado';
                    }
                  } else {
                    _nombresEmpleados[idEmpleado] = 'Empleado #$idEmpleado';
                  }
                } catch (e) {
                  _nombresEmpleados[idEmpleado] = 'Empleado #$idEmpleado';
                }
              }

              // 5. Ventas por tipo
              _ventasPorTipo.clear();
              for (final venta in ventasFiltradas) {
                final tipo = venta.tipoVenta ?? 'Sin tipo';
                _ventasPorTipo[tipo] = (_ventasPorTipo[tipo] ?? 0) + 1;
              }

              // 6. Productos más vendidos - obtener detalles de todas las ventas
              _productosVendidos.clear();
              _nombresProductos.clear();
              final productosUnicos = <int>{};

              for (final venta in ventasFiltradas) {
                final detallesResult = await _detalleVentaRepository
                    .getDetallesByVenta(venta.idVenta ?? 0);
                detallesResult.fold(
                  (failure) {},
                  (detalles) {
                    for (final detalle in detalles) {
                      _productosVendidos[detalle.idProducto] =
                          (_productosVendidos[detalle.idProducto] ?? 0) +
                              detalle.cantidad;
                      productosUnicos.add(detalle.idProducto);
                    }
                  },
                );
              }

              // Obtener nombres de productos
              for (final idProducto in productosUnicos) {
                try {
                  final producto = await _productosDataSource
                      .getProductById(idProducto.toString());
                  if (producto != null) {
                    _nombresProductos[idProducto] = producto.nombre;
                  } else {
                    _nombresProductos[idProducto] = 'Producto #$idProducto';
                  }
                } catch (e) {
                  _nombresProductos[idProducto] = 'Producto #$idProducto';
                }
              }

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
      title: 'Estadísticas de Ventas',
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
              _buildProductosMasVendidos(),
              const SizedBox(height: 24),
              _buildEmpleadoMasVentas(),
              const SizedBox(height: 24),
              _buildVentasPorTipo(),
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
                'Resumen de Ventas',
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
                titulo: 'Total Ventas',
                icon: Icons.point_of_sale,
                color: ThemeApp.primary,
                valor: '$_totalVentas',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Monto Total',
                icon: Icons.attach_money,
                color: Colors.green,
                valor: '\$${_montoTotalVendido.toStringAsFixed(2)}',
                onTap: () {},
              ),
              EstadisticaCardWidget(
                titulo: 'Promedio por Venta',
                icon: Icons.trending_flat,
                color: Colors.blue,
                valor: '\$${_promedioVenta.toStringAsFixed(2)}',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductosMasVendidos() {
    if (_productosVendidos.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordenar productos por cantidad descendente
    final productosOrdenados = _productosVendidos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
              Icon(Icons.restaurant_menu, color: ThemeApp.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Productos Más Vendidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...productosOrdenados.take(10).map((entry) {
            final nombreProducto =
                _nombresProductos[entry.key] ?? 'Producto #${entry.key}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      nombreProducto,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeApp.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeApp.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${entry.value} unidades',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeApp.primary,
                      ),
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

  Widget _buildEmpleadoMasVentas() {
    if (_ventasPorEmpleado.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordenar empleados por cantidad de ventas descendente
    final empleadosOrdenados = _ventasPorEmpleado.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final empleadoTop = empleadosOrdenados.first;
    final nombreEmpleado =
        _nombresEmpleados[empleadoTop.key] ?? 'Empleado #${empleadoTop.key}';

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
              Icon(Icons.person, color: ThemeApp.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Empleado con Más Ventas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeApp.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: ThemeApp.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreEmpleado,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ThemeApp.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${empleadoTop.value} venta${empleadoTop.value > 1 ? 's' : ''}',
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
          ),
          if (empleadosOrdenados.length > 1) ...[
            const SizedBox(height: 16),
            const Text(
              'Top 5 Empleados',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeApp.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...empleadosOrdenados.take(5).map((entry) {
              final nombre =
                  _nombresEmpleados[entry.key] ?? 'Empleado #${entry.key}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeApp.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value} venta${entry.value > 1 ? 's' : ''}',
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

  Widget _buildVentasPorTipo() {
    if (_ventasPorTipo.isEmpty) {
      return const SizedBox.shrink();
    }

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
              Icon(Icons.category, color: ThemeApp.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Ventas por Tipo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._ventasPorTipo.entries.map((entry) {
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
                    '${entry.value} venta${entry.value > 1 ? 's' : ''}',
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
      ),
    );
  }
}
