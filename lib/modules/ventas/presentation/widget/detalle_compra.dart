// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/services/enhanced_auth_service.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/mappers/compra_mapper.dart';
import 'package:resturant_funny/modules/ventas/domain/models/card_item_model.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/buscar_cliente_page.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/cart_item.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/input_dialog.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';

class DetalleCompra extends ConsumerStatefulWidget {
  final ProductoEntity initialProducto;
  final List<ProductoEntity> productosDisponibles;
  final List<MesaEntity> mesasDisponibles;
  const DetalleCompra({
    super.key,
    required this.initialProducto,
    required this.productosDisponibles,
    required this.mesasDisponibles,
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
  PersonaEntity? _clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    _resetearEstado();
  }

  @override
  void didUpdateWidget(DetalleCompra oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProducto.idProducto !=
        widget.initialProducto.idProducto) {
      _resetearEstado();
    }
  }

  void _resetearEstado() {
    _carrito.clear();
    _carrito.add(CartProduct(producto: widget.initialProducto, cantidad: 1));
    _aplicaIva = true;
    _productoAAgregar = null;
    _mesaSeleccionada = null;
    _conFactura = false;
    _conDelivery = false;
    _costoDelivery = 0.0;
  }

  double get _subtotal {
    return _carrito.fold(
        0.0, (acc, item) => acc + (item.producto.precio * item.cantidad));
  }

  double get _iva => _aplicaIva ? _subtotal * 0.15 : 0.0;
  double get _total => _subtotal + _iva + (_conDelivery ? _costoDelivery : 0.0);

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
      maxLength: 3,
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

  ///Validar datos obligatorios antes de finalizar compra
  bool _validarDatosObligatorios() {
    if (_carrito.isEmpty) {
      SnackHelper.show(context,
          message: "Debe agregar al menos un producto al carrito",
          isError: true);
      return false;
    }

    // Validar que se haya seleccionado una mesa
    if (_mesaSeleccionada == null) {
      SnackHelper.show(context,
          message: "Debe seleccionar una mesa para la venta", isError: true);
      return false;
    }

    // Validar que el subtotal sea mayor a 0
    if (_subtotal <= 0) {
      SnackHelper.show(context,
          message: "El subtotal debe ser mayor a 0", isError: true);
      return false;
    }

    // Validar que el total sea mayor a 0
    if (_total <= 0) {
      SnackHelper.show(context,
          message: "El total debe ser mayor a 0", isError: true);
      return false;
    }

    // Si es delivery, validar que se haya configurado el costo
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
    if (cliente == null) {
      ref.read(appStateProvider).setProcessLoading(false);
      SnackHelper.show(context,
          message: 'No se selecciono un cliente', isError: true);
      return;
    }
    ref.read(appStateProvider).setProcessLoading(true);
    final idUsuario = ref.read(userProvider).user?.idUsuario;

    final venta = CompraMapper.toVentaEntity(
      _subtotal,
      _costoDelivery,
      _conFactura,
      _conDelivery,
      _aplicaIva,
      _total,
      'Venta de producto',
      idUsuario?.toString() ?? EnhancedAuthService.currentUser?.usuario ?? '',
      _mesaSeleccionada?.idMesa ?? 0,
      _clienteSeleccionado!.identificacion,
    );
    debugPrint("venta: ${venta.toJson()}");

    SnackHelper.show(context,
        message: "Venta procesada exitosamente", isSuccess: true);

    Future.delayed(const Duration(seconds: 2), () {
      ref.read(appStateProvider).setProcessLoading(false);
    });
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
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          color: Colors.white,
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
                const SizedBox(height: 16),
                // Lista de items del carrito
                if (_carrito.isEmpty)
                  const Text("No hay productos en el carrito"),
                ...List.generate(_carrito.length, (index) {
                  final item = _carrito[index];
                  final producto = item.producto;
                  final precioLinea = producto.precio * item.cantidad;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                onPressed: () => _disminuirCantidad(index),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${item.cantidad}',
                                  style: const TextStyle(fontSize: 16)),
                              IconButton(
                                onPressed: () => _incrementarCantidad(index),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text('\$${precioLinea.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => _eliminarItem(index),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Eliminar",
                          ),
                        ],
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          color: Colors.white,
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
                  subtitleText: (mesa) =>
                      "Estado: ${mesa.estado ?? 'Disponible'}",
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
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Subtotal"),
                      Text('\$${_subtotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Text("IVA 15%"),
                        const SizedBox(width: 8),
                        Switch(
                          value: _aplicaIva,
                          onChanged: (v) => setState(() => _aplicaIva = v),
                        ),
                        const Text("Aplica"),
                      ]),
                      Text('\$${_iva.toStringAsFixed(2)}'),
                    ],
                  ),
                  const Divider(),
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
                  if (_conDelivery && _costoDelivery > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Costo Delivery"),
                        Text('\$${_costoDelivery.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total a pagar",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
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
