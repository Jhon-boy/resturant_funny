// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/services/enhanced_auth_service.dart';
import 'package:resturant_funny/core/utils/formatters.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/detalles_ventas_datasource.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/detalles_venta_impl.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/mappers/compra_mapper.dart';
import 'package:resturant_funny/modules/ventas/domain/models/card_item_model.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/detalle_venta_repository.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/ventas/presentation/factura_page.dart';
import 'package:resturant_funny/modules/ventas/presentation/pages/buscar_cliente_page.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/cart_item.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/porciones_widget.dart';
import 'package:resturant_funny/shared/enums/categorias_producto.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/input_dialog.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/inventario/data/datasource/inventario_data_source.dart';
import 'package:resturant_funny/modules/main/data/datasource/producto_insumo_datasource.dart';
import 'package:resturant_funny/shared/enums/metodo_pago.dart';

class DetalleCompra extends ConsumerStatefulWidget {
  final ProductoEntity? initialProducto;
  final List<ProductoEntity> productosDisponibles;
  final List<ProductoEntity> porcionesDisponibles;
  final List<MesaEntity> mesasDisponibles;
  const DetalleCompra({
    super.key,
    this.initialProducto,
    required this.productosDisponibles,
    required this.mesasDisponibles,
    required this.porcionesDisponibles,
  });

  @override
  ConsumerState<DetalleCompra> createState() => DetalleCompraState();
}

class DetalleCompraState extends ConsumerState<DetalleCompra> {
  final List<CartProduct> _carrito = [];
  bool _aplicaIva = true;
  ProductoEntity? _productoAAgregar;
  MesaEntity? _mesaSeleccionada;
  bool _conFactura = false;
  bool _conDelivery = false;
  double _costoDelivery = 0.0;
  MetodoPago _metodoPago = MetodoPago.EFECTIVO;

  late final VentaRepository _ventaRepository;
  late final DetalleVentaRepository _detalleVentaRepository;
  final TextEditingController comentarioController = TextEditingController();
  final TextEditingController montoRecibidoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ventaRepository = VentaRepositoryImpl(VentasRemoteDataSource(ref: ref));
    _detalleVentaRepository =
        DetalleVentaRepositoryImpl(DetalleVentaRemoteDataSource(ref: ref));
    _resetearEstado();
  }

  @override
  void didUpdateWidget(DetalleCompra oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProducto?.idProducto !=
        widget.initialProducto?.idProducto) {
      _resetearEstado();
    }
  }

  void _resetearEstado({resetProducto = false}) {
    _carrito.clear();
    if (!resetProducto && widget.initialProducto != null) {
      _carrito.add(CartProduct(producto: widget.initialProducto!, cantidad: 1));
    }
    _aplicaIva = false;
    _productoAAgregar = null;
    _mesaSeleccionada = null;
    _conFactura = false;
    _conDelivery = false;
    _costoDelivery = 0.0;
    _metodoPago = MetodoPago.EFECTIVO;
    comentarioController.text = '';
    montoRecibidoController.text = '';
  }

  double get _subtotal {
    return _carrito.fold(
        0.0, (acc, item) => acc + (item.producto.precio * item.cantidad));
  }

  double get _iva => _aplicaIva ? _subtotal * AppConstants.IVA : 0.0;
  double get _total => _subtotal + _iva + (_conDelivery ? _costoDelivery : 0.0);

  double get _montoRecibido {
    if (montoRecibidoController.text.trim().isEmpty) return 0.0;
    return double.tryParse(
          montoRecibidoController.text.trim().replaceAll(',', '.'),
        ) ??
        0.0;
  }

  double get _vuelto {
    final cambio = _montoRecibido - _total;
    return cambio > 0 ? cambio : 0.0;
  }

  void _incrementarCantidad(int index) {
    setState(() {
      _carrito[index].cantidad++;
    });
  }

  void _disminuirCantidad(int index) {
    setState(() {
      if (_carrito[index].cantidad > 1) {
        _carrito[index].cantidad--;
      }
    });
  }

  void _eliminarItem(int index) {
    setState(() {
      _carrito.removeAt(index);
      SnackHelper.show(context, message: 'Producto Eliminado', isError: true);
    });
  }

  void _agregarProductoSeleccionado() {
    final seleccionado = _productoAAgregar;
    if (seleccionado == null) return;
    final indexExistente = _carrito
        .indexWhere((e) => e.producto.idProducto == seleccionado.idProducto);
    setState(() {
      if (indexExistente >= 0) {
        _carrito[indexExistente].cantidad++;
      } else {
        _carrito.add(CartProduct(producto: seleccionado, cantidad: 1));
      }
      _productoAAgregar = null;
      SnackHelper.show(context, message: 'Producto agregago', isSuccess: true);
    });
  }

  Future<void> _configurarDelivery() async {
    final costo = await InputDialog.showTextInput(
      context: context,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      initialValue: _costoDelivery > 0 ? _costoDelivery.toString() : null,
      title: 'Costo de Delivery',
      label: 'Costo de Delivery',
      maxLength: 4,
    );
    debugPrint("costo: $costo");
    if (costo != null) {
      setState(() {
        _costoDelivery = double.parse(costo);
      });
    } else {
      setState(() {
        _conDelivery = false;
      });
    }
  }

  Future<void> _showPorcionesDialog() async {
    final porcionesSeleccionadas = await showDialog<Map<int, int>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return PorcionesWidget(
          porciones: widget.porcionesDisponibles,
          onSelected: (porciones) {
            Navigator.of(dialogContext).pop(porciones);
          },
        );
      },
    );

    if (porcionesSeleccionadas != null && porcionesSeleccionadas.isNotEmpty) {
      _agregarPorcionesAlCarrito(porcionesSeleccionadas);
    }
  }

  void _agregarPorcionesAlCarrito(Map<int, int> porcionesSeleccionadas) {
    int totalAgregadas = 0;
    setState(() {
      porcionesSeleccionadas.forEach((porcionId, cantidad) {
        if (cantidad > 0) {
          try {
            final porcion = widget.porcionesDisponibles.firstWhere(
              (p) => p.idProducto == porcionId,
            );

            final indexExistente = _carrito.indexWhere(
              (item) => item.producto.idProducto == porcionId,
            );

            if (indexExistente >= 0) {
              _carrito[indexExistente].cantidad += cantidad;
            } else {
              _carrito.add(CartProduct(producto: porcion, cantidad: cantidad));
            }
            totalAgregadas += cantidad;
          } catch (e) {
            debugPrint('Error al agregar porción $porcionId: $e');
          }
        }
      });
    });

    if (totalAgregadas > 0) {
      SnackHelper.show(
        context,
        message:
            '$totalAgregadas ${totalAgregadas == 1 ? 'porción agregada' : 'porciones agregadas'} al carrito',
        isSuccess: true,
      );
    }
  }

  ///Validar datos obligatorios antes de finalizar compra
  bool _validarDatosObligatorios() {
    if (_carrito.isEmpty) {
      SnackHelper.show(context,
          message: "Debe agregar al menos un producto al carrito",
          isError: true);
      return false;
    }

    if (_subtotal <= 0) {
      SnackHelper.show(context,
          message: "El subtotal debe ser mayor a 0", isError: true);
      return false;
    }

    if (_total <= 0) {
      SnackHelper.show(context,
          message: "El total debe ser mayor a 0", isError: true);
      return false;
    }

    if (_conDelivery && _costoDelivery <= 0) {
      SnackHelper.show(context,
          message: "Debe configurar el costo de delivery", isError: true);
      return false;
    }

    final idUsuario = ref.read(userProvider).user?.idUsuario;
    if (idUsuario == null) {
      SnackHelper.show(context,
          message: "Debe estar autenticado para realizar la venta",
          isError: true);
      return false;
    }

    // Validar monto recibido solo si el usuario ingresó un valor
    if (_metodoPago == MetodoPago.EFECTIVO) {
      final texto = montoRecibidoController.text.trim();
      if (texto.isNotEmpty) {
        final montoRecibido = _montoRecibido;
        if (montoRecibido < _total) {
          SnackHelper.show(context,
              message:
                  "El monto recibido debe ser mayor o igual al total a pagar",
              isError: true);
          return false;
        }
      }
    }
    return true;
  }

  ///Finalizar la compra
  void _finalizarCompra() async {
    if (!_validarDatosObligatorios()) {
      return;
    }
    final cliente = await BuscarClienteWidget.show(
      context: context,
      titulo: "Seleccionar Cliente",
    );
    final clienteEfectivo = cliente ??
        PersonaEntity(
          identificacion: 'CONSUMIDOR_FINAL',
          nombres: 'Consumidor',
          apellidos: 'Final',
        );
    ref.read(appStateProvider).setProcessLoading(true);
    final user = ref.read(userProvider).user;

    final montoRecibido = _montoRecibido;

    final venta = CompraMapper.toVentaEntity(
      _subtotal,
      _costoDelivery,
      _conFactura,
      _conDelivery,
      _aplicaIva,
      _total,
      montoRecibido,
      '${comentarioController.text} | Venta de producto | ${_metodoPago.label}',
      user?.idUsuario?.toString() ??
          EnhancedAuthService.currentUser?.usuario ??
          '',
      _mesaSeleccionada?.idMesa ?? 0,
      _metodoPago.value,
      clienteEfectivo.identificacion,
    );

    final ventaFinalizado = await _ventaRepository.createVenta(venta, user!);
    ventaFinalizado.fold((error) {
      ref.read(appStateProvider).setProcessLoading(false);
      DialogHelper.error(context,
          message: "Error al procesar la venta: $error", onConfirmed: () {});
    }, (ventaCreada) async {
      final detallesGuardados =
          await _guardarDetalleVenta(_carrito, ventaCreada);

      ref.read(appStateProvider).setProcessLoading(false);

      if (detallesGuardados) {
        await _descontarStock(_carrito);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => FacturaPage(
                    venta: ventaCreada,
                    carrito: _carrito,
                  )),
          (route) => false,
        );
      } else {
        DialogHelper.error(context,
            message:
                "La venta se creó pero hubo errores al guardar algunos productos",
            onConfirmed: () {});
      }
    });
  }

  Future<bool> _guardarDetalleVenta(
      List<CartProduct> carrito, VentaEntity venta) async {
    ref.read(appStateProvider).setProcessLoading(true);
    final user = ref.read(userProvider).user;
    bool todosLosDetallesGuardados = true;

    for (var item in carrito) {
      final detalleVenta = CompraMapper.toDetalleVenta(venta, item.cantidad,
          item.producto, user!.idUsuario.toString(), _metodoPago.value);

      final detalleVentaFinalizado =
          await _detalleVentaRepository.createDetalle(detalleVenta, user);

      detalleVentaFinalizado.fold((error) {
        debugPrint(
            "Error al guardar detalle para producto ${item.producto.nombre}: $error");
        todosLosDetallesGuardados = false;
      }, (detalleVenta) {
        debugPrint(
            "Detalle guardado correctamente para producto ${item.producto.nombre}");
      });
    }
    return todosLosDetallesGuardados;
  }

  Future<void> _descontarStock(List<CartProduct> carrito) async {
    final insumoDatasource = ProductoInsumoDatasource(ref: ref);
    final inventarioDatasource = InventarioRemoteDataSource(ref: ref);
    final List<String> sinInsumos = [];

    for (final item in carrito) {
      try {
        final insumos =
            await insumoDatasource.getByProducto(item.producto.idProducto!);
        if (insumos.isEmpty) {
          sinInsumos.add(item.producto.nombre);
          continue;
        }
        for (final insumo in insumos) {
          if (insumo.idInventario == null || insumo.cantidad == null) continue;
          final inventario =
              await inventarioDatasource.getInventarioById(insumo.idInventario!);
          if (inventario == null) continue;
          final unidades = item.cantidad * insumo.cantidad!;
          final nuevoStock =
              ((inventario.stock ?? 0) - unidades).clamp(0, 999999).toInt();
          await inventarioDatasource
              .updateInventario(insumo.idInventario!, {'STOCK': nuevoStock});
        }
      } catch (e) {
        debugPrint(
            'Error al descontar stock de ${item.producto.nombre}: $e');
      }
    }

    if (sinInsumos.isNotEmpty && mounted) {
      SnackHelper.show(
        context,
        message:
            'Sin insumos configurados: ${sinInsumos.join(', ')}',
        isWarning: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtil.byWidth<double>(
      context,
      small: 16,
      medium: 24,
      large: 32,
      xl: 48,
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: ThemeApp.cardColors,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart,
                        color: ThemeApp.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "Carrito",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown<ProductoEntity>(
                        value: _productoAAgregar,
                        label: "Agregar producto",
                        hint: "Selecciona un producto",
                        items: widget.productosDisponibles,
                        displayText: (producto) => producto.nombre,
                        onChanged: (v) => setState(() => _productoAAgregar = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _agregarProductoSeleccionado,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: ThemeApp.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: CustomButton(
                            colorButton: ThemeApp.success.withOpacity(0.7),
                            colorText: ThemeApp.baseText,
                            text: "Añadir Porciones",
                            icon: Icons.restaurant,
                            onPressed: () {
                              _showPorcionesDialog();
                            }))
                  ],
                ),
                const SizedBox(height: 16),
                // Lista de items del carrito
                if (_carrito.isEmpty)
                  const Text("No hay productos en el carrito"),
                Builder(
                  builder: (context) {
                    final productosNormales = <int>[];
                    final indicesPorciones = <int>[];

                    for (int i = 0; i < _carrito.length; i++) {
                      if (_carrito[i].producto.categoria.toUpperCase() ==
                          ProductosCategorias.PORCION.code) {
                        indicesPorciones.add(i);
                      } else {
                        productosNormales.add(i);
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Productos normales
                        ...productosNormales.map((index) {
                          final item = _carrito[index];
                          final producto = item.producto;
                          final precioLinea = producto.precio * item.cantidad;
                          return Card(
                            color: ThemeApp.cardColors,
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        MiniImagen(producto: producto),
                                        const SizedBox(height: 8),
                                        Text(
                                          producto.nombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${producto.precio.toStringAsFixed(2)} c/u",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _disminuirCantidad(index),
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                      ),
                                      Text('${item.cantidad}',
                                          style: const TextStyle(fontSize: 16)),
                                      IconButton(
                                        onPressed: () =>
                                            _incrementarCantidad(index),
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Text('\$${precioLinea.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    onPressed: () => _eliminarItem(index),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    tooltip: "Eliminar",
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        // Separador para porciones
                        if (indicesPorciones.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade400,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OTROS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade400,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...indicesPorciones.map((index) {
                            final item = _carrito[index];
                            final producto = item.producto;
                            final precioLinea = producto.precio * item.cantidad;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 3,
                              color: ThemeApp.cardColors,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: ThemeApp.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Nombre y cantidad
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            producto.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Cantidad: ${item.cantidad}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Total
                                    Text(
                                      '\$${precioLinea.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: ThemeApp.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Controles de cantidad
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              _disminuirCantidad(index),
                                          icon: const Icon(
                                              Icons.remove_circle_outline,
                                              size: 20),
                                          color: ThemeApp.primary,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            '${item.cantidad}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _incrementarCantidad(index),
                                          icon: const Icon(
                                              Icons.add_circle_outline,
                                              size: 20),
                                          color: ThemeApp.primary,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 4),
                                    // Botón eliminar
                                    IconButton(
                                      onPressed: () => _eliminarItem(index),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      tooltip: "Eliminar",
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    );
                  },
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          color: ThemeApp.cardColors,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.table_restaurant,
                        color: ThemeApp.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "Mesa de la Venta",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CustomDropdown<MesaEntity>(
                  value: _mesaSeleccionada,
                  label: "Mesa de la Venta",
                  hint: "Selecciona la mesa",
                  items: widget.mesasDisponibles,
                  displayText: (mesa) => "Mesa ${mesa.numero ?? 'N/A'}",
                  onChanged: (mesa) {
                    setState(() {
                      _mesaSeleccionada = mesa;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
            color: ThemeApp.cardColors,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Text("Factura"),
                        const SizedBox(width: 8),
                        Switch(
                          value: _conFactura,
                          onChanged: (v) => setState(() => _conFactura = v),
                        ),
                      ]),
                      Row(children: [
                        const Text("Es Delivery"),
                        const SizedBox(width: 8),
                        Switch(
                          value: _conDelivery,
                          onChanged: (v) {
                            setState(() => _conDelivery = v);
                            if (v) {
                              _configurarDelivery();
                            } else {
                              setState(() => _costoDelivery = 0.0);
                            }
                          },
                        ),
                      ]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Text("IVA ${AppConstants.IVA * 100}%"),
                        const SizedBox(width: 8),
                        Switch(
                          value: _aplicaIva,
                          onChanged: (v) => setState(() => _aplicaIva = v),
                        ),
                      ]),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Método de pago
                  Row(
                    children: [
                      const Icon(Icons.payment,
                          color: ThemeApp.primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "Método de Pago",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomDropdown<MetodoPago>(
                    value: _metodoPago,
                    label: "Método de Pago",
                    hint: "Selecciona el método de pago",
                    items: MetodoPago.all,
                    displayText: (metodo) => metodo.label,
                    onChanged: (metodo) {
                      setState(() {
                        final metodoSeleccionado =
                            metodo ?? MetodoPago.EFECTIVO;
                        _metodoPago = metodoSeleccionado;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Monto recibido (solo visible para efectivo)
                  if (_metodoPago == MetodoPago.EFECTIVO) ...[
                    TextFormField(
                      controller: montoRecibidoController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      onChanged: (_) => setState(() {}),
                      decoration: ThemeApp.inputDecoration(
                        "Monto recibido",
                        "Ingrese el monto recibido",
                        Icons.payments,
                        isRequired: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        maxLength: AppConstants.MAX_CARACTERES_TITULOS,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                          LetterOnlyTextFormatter()
                        ],
                        controller: comentarioController,
                        decoration: ThemeApp.inputDecoration(
                          "Comentario",
                          "Ingrese un comentario",
                          Icons.comment_bank,
                          isRequired: false,
                        ),
                      ),
                    )
                  ]),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Iva ${AppConstants.IVA * 100}%",
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                      Text('\$${_iva.toStringAsFixed(2)}',
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                    ],
                  ),
                  if (_conDelivery && _costoDelivery > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Costo Delivery"),
                        Text('\$${_costoDelivery.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Cambio",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${_vuelto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Subtotal"),
                      Text('\$${_subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total a pagar",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: ThemeApp.apple)),
                      Text('\$${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: ThemeApp.apple)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                        text: "Finalizar Compra",
                        icon: Icons.monetization_on,
                        isLoading: ref.watch(appStateProvider).isProcessLoading,
                        onPressed: () {
                          _finalizarCompra();
                        }),
                  ),
                ],
              ),
            )),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: content,
    );
  }
}
