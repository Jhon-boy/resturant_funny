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
import 'package:resturant_funny/modules/ventas/data/datasource/facturas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/detalles_venta_impl.dart';
import 'package:resturant_funny/modules/ventas/data/repository/facturas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/detalle_venta_repository.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/factura_repository.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/persona_repository_impl.dart';
import 'package:resturant_funny/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/repository/persona_repository.dart';
import 'package:resturant_funny/modules/user/domain/repository/usuario_repository.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadisticas_basicas_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/expandible_section_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/grafico_ventas_completo_widget.dart';
import 'package:resturant_funny/modules/reportes/domain/models/estadisticas_ventas_model.dart';
import 'package:resturant_funny/modules/reportes/domain/services/estadisticas_ventas_service.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/enums/categorias_producto.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/not_found_card.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/factura_entity.dart';

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
  late FacturasRepository _facturasRepository;
  late MesaRepository _mesaRepository;
  late PersonasRepository _personasRepository;
  late UsuariosRepository _usuariosRepository;

  // Filtros
  SucursalEntity? _sucursalSeleccionada;
  DateTime? _fechaInicio;
  DateTime? _fechaHasta;

  // Estadísticas completas
  EstadisticasVentasCompletas? _estadisticas;
  static const int MAX_DIAS = 30;
  final Map<int, ProductoEntity> _productosCache = {};

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
      _facturasRepository = FacturasRepositoryImpl(
        FacturasRemoteDataSource(ref: ref),
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
    if (diferencia.inDays > MAX_DIAS) {
      DialogHelper.error(context,
          message: 'El rango máximo es de $MAX_DIAS días', onConfirmed: () {});
      return;
    }

    ref.read(appStateProvider.notifier).setLoading(true);

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
              _estadisticas = null;
            });
            if (mounted) {
              ref.read(appStateProvider.notifier).setLoading(false);
            }
            return;
          }

          final idsMesas = mesas.map((m) => m.idMesa ?? 0).toList();
          final nombresMesas = <int, String>{};
          for (final mesa in mesas) {
            if (mesa.idMesa != null) {
              nombresMesas[mesa.idMesa!] = mesa.numeroFormateado;
            }
          }

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

              // 3. Obtener facturas
              final facturasResult = await _facturasRepository.getAllFacturas(
                fechaDesde: _fechaInicio,
                fechaHasta: _fechaHasta?.add(const Duration(days: 1)),
              );

              final facturas = facturasResult.fold(
                (failure) => <FacturaEntity>[],
                (facturas) => facturas,
              );

              // 4. Obtener detalles de venta con productos
              final idsVentas = ventasFiltradas.map((v) => v.idVenta!).toList();
              final detallesResult = await _detalleVentaRepository
                  .getDetallesConProductosBySucursal(
                idsVentas,
                fechaDesde: _fechaInicio,
                fechaHasta: _fechaHasta,
              );

              final detallesConProductos = detallesResult.fold(
                (failure) => <Map<String, dynamic>>[],
                (detalles) => detalles,
              );

              // 5. Procesar empleados
              final empleadosUnicos = <int>{};
              final nombresEmpleados = <int, String>{};
              final montosPorEmpleado = <int, double>{};

              for (final venta in ventasFiltradas) {
                empleadosUnicos.add(venta.idEmpleado);
                montosPorEmpleado[venta.idEmpleado] =
                    (montosPorEmpleado[venta.idEmpleado] ?? 0.0) +
                        (venta.total ?? 0.0);
              }

              for (final idEmpleado in empleadosUnicos) {
                try {
                  final usuarioResult =
                      await _usuariosRepository.getUsuarioById(idEmpleado);
                  usuarioResult.fold(
                    (failure) {
                      nombresEmpleados[idEmpleado] = 'Empleado #$idEmpleado';
                    },
                    (usuario) async {
                      final personaResult = await _personasRepository
                          .getPersonaByIdentificacion(usuario.identificacion);
                      personaResult.fold(
                        (failure) {
                          nombresEmpleados[idEmpleado] =
                              'Empleado #$idEmpleado';
                        },
                        (persona) {
                          nombresEmpleados[idEmpleado] =
                              '${persona.nombres} ${persona.apellidos}';
                        },
                      );
                    },
                  );
                } catch (e) {
                  nombresEmpleados[idEmpleado] = 'Empleado #$idEmpleado';
                }
              }

              // 6. Procesar clientes
              final clientesUnicos = <String>{};
              final nombresClientes = <String, String>{};
              final montosPorCliente = <String, double>{};

              for (final venta in ventasFiltradas) {
                clientesUnicos.add(venta.cliente);
                montosPorCliente[venta.cliente] =
                    (montosPorCliente[venta.cliente] ?? 0.0) +
                        (venta.total ?? 0.0);
              }

              for (final clienteId in clientesUnicos) {
                try {
                  final personaResult = await _personasRepository
                      .getPersonaByIdentificacion(clienteId);
                  personaResult.fold(
                    (failure) {
                      nombresClientes[clienteId] = 'Cliente #$clienteId';
                    },
                    (persona) {
                      nombresClientes[clienteId] =
                          '${persona.nombres} ${persona.apellidos}';
                    },
                  );
                } catch (e) {
                  nombresClientes[clienteId] = 'Cliente #$clienteId';
                }
              }

              // 7. Procesar productos y porciones
              final productosVendidos = <int, int>{};
              final nombresProductos = <int, String>{};
              final porcionesVendidas = <int, int>{};
              final nombresPorciones = <int, String>{};
              final montosPorMesa = <int, double>{};

              final categoriasPermitidas = [
                ProductosCategorias.PRODUCTO.code,
                ProductosCategorias.COMIDA.code,
              ];

              for (final detalleJson in detallesConProductos) {
                final productoJson =
                    detalleJson['TPRODUCTO'] as Map<String, dynamic>?;
                if (productoJson == null) continue;

                final producto = ProductoEntity.fromJson(productoJson);
                final cantidad = detalleJson['CANTIDAD'] as int;
                final idProducto = producto.idProducto!;

                _productosCache[idProducto] = producto;

                if (producto.categoria == ProductosCategorias.PORCION.code) {
                  porcionesVendidas[idProducto] =
                      (porcionesVendidas[idProducto] ?? 0) + cantidad;
                  nombresPorciones[idProducto] = producto.nombre;
                } else if (categoriasPermitidas.contains(producto.categoria)) {
                  productosVendidos[idProducto] =
                      (productosVendidos[idProducto] ?? 0) + cantidad;
                  nombresProductos[idProducto] = producto.nombre;
                }
              }

              // 8. Calcular montos por mesa
              for (final venta in ventasFiltradas) {
                montosPorMesa[venta.idMesa] =
                    (montosPorMesa[venta.idMesa] ?? 0.0) + (venta.total ?? 0.0);
              }

              // 9. Calcular estadísticas completas
              final estadisticas =
                  EstadisticasVentasService.calcularEstadisticas(
                ventas: ventasFiltradas,
                facturas: facturas,
                nombresEmpleados: nombresEmpleados,
                nombresClientes: nombresClientes,
                nombresMesas: nombresMesas,
                nombresProductos: nombresProductos,
                nombresPorciones: nombresPorciones,
                productosVendidos: productosVendidos,
                porcionesVendidas: porcionesVendidas,
                montosPorEmpleado: montosPorEmpleado,
                montosPorCliente: montosPorCliente,
                montosPorMesa: montosPorMesa,
                fechaInicio: _fechaInicio!,
                fechaHasta: _fechaHasta!,
                detallesConProductos: detallesConProductos,
              );

              setState(() {
                _estadisticas = estadisticas;
              });

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
          DateRangeWidget(
            title: 'Rango de Fechas (máx. $MAX_DIAS días)',
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
                    _fechaHasta = desde.add(const Duration(days: MAX_DIAS));
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
            },
          ),
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
    if (ref.watch(appStateProvider).isLoading) {
      return Center(child: ShimmerWidget.list(itemCount: 3));
    }

    if (_estadisticas == null) {
      return const NotFoundCard(
        message: 'No se encontraron datos para el período seleccionado',
        icon: Icons.bar_chart_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEstadisticasBasicas(),
        const SizedBox(height: 24),
        _buildGraficoVentas(),
        const SizedBox(height: 24),
        _buildProductosConVentas(),
        const SizedBox(height: 24),
        _buildPorcionesMasVendidas(),
        const SizedBox(height: 24),
        _buildVentasPorEmpleado(),
        const SizedBox(height: 24),
        _buildClienteTop(),
        const SizedBox(height: 24),
        _buildVentasPorMesa(),
        const SizedBox(height: 24),
        _buildVentasPorTipo(),
        const SizedBox(height: 24),
        _buildEstadisticasAdicionales(),
      ],
    );
  }

  Widget _buildEstadisticasBasicas() {
    if (_estadisticas == null) return const SizedBox.shrink();

    return EstadisticasBasicasWidget(
      titulo: 'Resumen de Ventas',
      icono: Icons.analytics,
      estadisticas: [
        EstadisticaBasica(
          titulo: 'Total Ventas',
          valor: '${_estadisticas!.totalVentas}',
          icon: Icons.point_of_sale,
          color: ThemeApp.primary,
        ),
        EstadisticaBasica(
          titulo: 'Monto Total',
          valor: '\$${_estadisticas!.montoTotalVendido.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        EstadisticaBasica(
          titulo: 'Promedio por Venta',
          valor: '\$${_estadisticas!.promedioVenta.toStringAsFixed(2)}',
          icon: Icons.trending_flat,
          color: Colors.blue,
        ),
        EstadisticaBasica(
          titulo: 'Promedio por Día',
          valor: '\$${_estadisticas!.promedioPorDia.toStringAsFixed(2)}',
          icon: Icons.calendar_today,
          color: Colors.orange,
        ),
        EstadisticaBasica(
          titulo: 'Total Facturas',
          valor: '${_estadisticas!.totalFacturas}',
          icon: Icons.receipt,
          color: Colors.purple,
        ),
        EstadisticaBasica(
          titulo: 'Monto Facturado',
          valor: '\$${_estadisticas!.montoTotalFacturado.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildGraficoVentas() {
    if (_estadisticas == null || _estadisticas!.ventasPorDia.isEmpty) {
      return const SizedBox.shrink();
    }

    return GraficoVentasCompletoWidget(
      ventasPorDia: _estadisticas!.ventasPorDia,
      mostrarMontos: true,
    );
  }

  Widget _buildProductosConVentas() {
    if (_estadisticas == null || _estadisticas!.productosConVentas.isEmpty) {
      return const SizedBox.shrink();
    }

    final productosIniciales =
        _estadisticas!.productosConVentas.take(5).toList();
    final tieneMas = _estadisticas!.productosConVentas.length > 5;

    Widget _buildItemProducto(ProductoVentaCount producto) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombreProducto,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ThemeApp.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${producto.cantidadUnidades} unidades',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeApp.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeApp.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${producto.cantidadVentas} ventas',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeApp.primary,
                    ),
                  ),
                  if (producto.montoTotal > 0)
                    Text(
                      '\$${producto.montoTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 11,
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

    return ExpandibleSectionWidget(
      titulo: 'Productos Vendidos',
      icono: Icons.restaurant_menu,
      contenidoInicial: Column(
        children: productosIniciales.map(_buildItemProducto).toList(),
      ),
      contenido: Column(
        children:
            _estadisticas!.productosConVentas.map(_buildItemProducto).toList(),
      ),
      mostrarVerMas: tieneMas,
    );
  }

  Widget _buildPorcionesMasVendidas() {
    if (_estadisticas == null || _estadisticas!.porcionesVendidas.isEmpty) {
      return const SizedBox.shrink();
    }

    final porcionesIniciales =
        _estadisticas!.porcionesVendidas.take(5).toList();
    final tieneMas = _estadisticas!.porcionesVendidas.length > 5;

    Widget _buildItemPorcion(PorcionStats porcion) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                porcion.nombreProducto,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeApp.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeApp.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${porcion.cantidadVendida} unidades',
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
    }

    return ExpandibleSectionWidget(
      titulo: 'Porciones Más Vendidas',
      icono: Icons.fastfood,
      contenidoInicial: Column(
        children: [
          if (_estadisticas!.porcionTop != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
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
                          _estadisticas!.porcionTop!.nombreProducto,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_estadisticas!.porcionTop!.cantidadVendida} unidades',
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
          ...porcionesIniciales.map(_buildItemPorcion).toList(),
        ],
      ),
      contenido: Column(
        children: [
          if (_estadisticas!.porcionTop != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
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
                          _estadisticas!.porcionTop!.nombreProducto,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_estadisticas!.porcionTop!.cantidadVendida} unidades',
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
          ..._estadisticas!.porcionesVendidas.map(_buildItemPorcion).toList(),
        ],
      ),
      mostrarVerMas: tieneMas,
    );
  }

  Widget _buildVentasPorEmpleado() {
    if (_estadisticas == null || _estadisticas!.ventasPorEmpleado.isEmpty) {
      return const SizedBox.shrink();
    }

    final empleadosIniciales =
        _estadisticas!.ventasPorEmpleado.take(5).toList();
    final tieneMas = _estadisticas!.ventasPorEmpleado.length > 5;

    Widget _buildItemEmpleado(VentaEmpleadoStats empleado) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                empleado.nombreEmpleado,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeApp.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeApp.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${empleado.totalVentas} venta${empleado.totalVentas > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeApp.primary,
                    ),
                  ),
                  Text(
                    '\$${empleado.montoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
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

    return ExpandibleSectionWidget(
      titulo: 'Ventas por Empleado',
      icono: Icons.person,
      contenidoInicial: Column(
        children: [
          if (_estadisticas!.empleadoTop != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
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
                          _estadisticas!.empleadoTop!.nombreEmpleado,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_estadisticas!.empleadoTop!.totalVentas} venta${_estadisticas!.empleadoTop!.totalVentas > 1 ? 's' : ''} - \$${_estadisticas!.empleadoTop!.montoTotal.toStringAsFixed(2)}',
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
          ...empleadosIniciales.map(_buildItemEmpleado).toList(),
        ],
      ),
      contenido: Column(
        children: [
          if (_estadisticas!.empleadoTop != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
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
                          _estadisticas!.empleadoTop!.nombreEmpleado,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_estadisticas!.empleadoTop!.totalVentas} venta${_estadisticas!.empleadoTop!.totalVentas > 1 ? 's' : ''} - \$${_estadisticas!.empleadoTop!.montoTotal.toStringAsFixed(2)}',
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
          ..._estadisticas!.ventasPorEmpleado.map(_buildItemEmpleado).toList(),
        ],
      ),
      mostrarVerMas: tieneMas,
    );
  }

  Widget _buildClienteTop() {
    if (_estadisticas == null || _estadisticas!.ventasPorCliente.isEmpty) {
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
              Icon(Icons.people, color: ThemeApp.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Cliente que Más Compra',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_estadisticas!.clienteTop != null) ...[
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
                          _estadisticas!.clienteTop!.nombreCliente,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_estadisticas!.clienteTop!.totalCompras} compra${_estadisticas!.clienteTop!.totalCompras > 1 ? 's' : ''} - \$${_estadisticas!.clienteTop!.montoTotal.toStringAsFixed(2)}',
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
            if (_estadisticas!.ventasPorCliente.length > 1) ...[
              const SizedBox(height: 16),
              const Text(
                'Top 5 Clientes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeApp.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._estadisticas!.ventasPorCliente.take(5).map((cliente) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cliente.nombreCliente,
                          style: const TextStyle(
                            fontSize: 14,
                            color: ThemeApp.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '${cliente.totalCompras} compra${cliente.totalCompras > 1 ? 's' : ''}',
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
        ],
      ),
    );
  }

  Widget _buildVentasPorMesa() {
    if (_estadisticas == null || _estadisticas!.ventasPorMesa.isEmpty) {
      return const SizedBox.shrink();
    }

    final mesasIniciales = _estadisticas!.ventasPorMesa.take(5).toList();
    final tieneMas = _estadisticas!.ventasPorMesa.length > 5;

    Widget _buildItemMesa(MesaStats mesa) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                mesa.nombreMesa,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeApp.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeApp.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${mesa.totalVentas} venta${mesa.totalVentas > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeApp.primary,
                    ),
                  ),
                  Text(
                    '\$${mesa.montoTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
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

    return ExpandibleSectionWidget(
      titulo: 'Ventas por Mesa',
      icono: Icons.table_restaurant,
      contenidoInicial: Column(
        children: [
          if (_estadisticas!.mesaTop != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
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
                          _estadisticas!.mesaTop!.nombreMesa,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_estadisticas!.mesaTop!.totalVentas} venta${_estadisticas!.mesaTop!.totalVentas > 1 ? 's' : ''} - \$${_estadisticas!.mesaTop!.montoTotal.toStringAsFixed(2)}',
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
          ...mesasIniciales.map(_buildItemMesa).toList(),
        ],
      ),
      contenido: Column(
        children: [
          if (_estadisticas!.mesaTop != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
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
                          _estadisticas!.mesaTop!.nombreMesa,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_estadisticas!.mesaTop!.totalVentas} venta${_estadisticas!.mesaTop!.totalVentas > 1 ? 's' : ''} - \$${_estadisticas!.mesaTop!.montoTotal.toStringAsFixed(2)}',
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
          ..._estadisticas!.ventasPorMesa.map(_buildItemMesa).toList(),
        ],
      ),
      mostrarVerMas: tieneMas,
    );
  }

  Widget _buildVentasPorTipo() {
    if (_estadisticas == null || _estadisticas!.ventasPorTipo.isEmpty) {
      return const SizedBox.shrink();
    }

    final tiposOrdenados = _estadisticas!.ventasPorTipo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final tiposIniciales = tiposOrdenados.take(5).toList();
    final tieneMas = tiposOrdenados.length > 5;

    Widget _buildItemTipo(MapEntry<String, int> entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeApp.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeApp.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${entry.value} venta${entry.value > 1 ? 's' : ''}',
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
    }

    return ExpandibleSectionWidget(
      titulo: 'Ventas por Tipo',
      icono: Icons.category,
      contenidoInicial: Column(
        children: tiposIniciales.map(_buildItemTipo).toList(),
      ),
      contenido: Column(
        children: tiposOrdenados.map(_buildItemTipo).toList(),
      ),
      mostrarVerMas: tieneMas,
    );
  }

  Widget _buildEstadisticasAdicionales() {
    if (_estadisticas == null) return const SizedBox.shrink();

    return EstadisticasBasicasWidget(
      titulo: 'Estadísticas Adicionales',
      icono: Icons.insights,
      estadisticas: [
        EstadisticaBasica(
          titulo: 'Ticket Promedio',
          valor: '\$${_estadisticas!.ticketPromedio.toStringAsFixed(2)}',
          icon: Icons.receipt_long,
          color: Colors.blue,
        ),
        EstadisticaBasica(
          titulo: 'Ventas con Delivery',
          valor: '${_estadisticas!.ventasConDelivery}',
          icon: Icons.delivery_dining,
          color: Colors.orange,
        ),
        EstadisticaBasica(
          titulo: 'Monto Total Delivery',
          valor: '\$${_estadisticas!.montoTotalDelivery.toStringAsFixed(2)}',
          icon: Icons.local_shipping,
          color: Colors.teal,
        ),
        EstadisticaBasica(
          titulo: 'Promedio Delivery',
          valor: _estadisticas!.ventasConDelivery > 0
              ? '\$${(_estadisticas!.montoTotalDelivery / _estadisticas!.ventasConDelivery).toStringAsFixed(2)}'
              : '\$0.00',
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }
}
