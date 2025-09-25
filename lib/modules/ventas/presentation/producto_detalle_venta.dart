import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/main/presentation/widget/shimer_producto.dart';
import 'package:resturant_funny/modules/ventas/domain/models/card_item_model.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/cart_item.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';

class ProductoDetallePage extends ConsumerStatefulWidget {
  final ProductoEntity producto;
  final Function(int)? onSectionChange;

  const ProductoDetallePage({
    super.key,
    required this.producto,
    this.onSectionChange,
  });

  @override
  ConsumerState<ProductoDetallePage> createState() =>
      _ProductoDetallePageState();
}

class _ProductoDetallePageState extends ConsumerState<ProductoDetallePage> {
  ProductoEntity? _productoActualizado;
  List<ProductoEntity> productosLista = [];
  List<MesaEntity> mesasLista = [];
  late final ProductosRepository _productosRepository;
  late final MesaRepository _mesaRepository;

  @override
  void initState() {
    super.initState();
    _productosRepository = ProductosRepositoryImpl(
      ProductosRemoteDataSource(ref: ref),
    );
    _mesaRepository = MesaRepositoryImpl(
      MesasRemoteDataSource(ref: ref),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarProducto();
      _cargarProductos();
      _cargarMesas();
    });
  }

  Future<void> _cargarProducto() async {
    try {
      final result = await _productosRepository
          .getProductById(widget.producto.idProducto.toString());
      result.fold((failure) {
        SnackHelper.show(context,
            message: "Error el cargar la informacion del producto",
            isError: true);
        setState(() {
          _productoActualizado = widget.producto;
        });
      }, (producto) {
        setState(() {
          _productoActualizado = producto;
        });
      });
    } catch (_) {
      setState(() {
        _productoActualizado = widget.producto;
      });
    }
  }

  Future<void> _cargarProductos() async {
    try {
      final result =
          await _productosRepository.getProductos(widget.producto.idSucursal);
      result.fold((failure) {
        DialogHelper.error(context,
            message: "Error al cargar productos", onConfirmed: () {});
      }, (productos) {
        setState(() {
          productosLista = productos;
        });
      });
    } catch (e) {
      debugPrint("Error al obtener productos");
    }
  }

  Future<void> _cargarMesas() async {
    try {
      final result =
          await _mesaRepository.getMesasBySucursal(widget.producto.idSucursal);
      result.fold((failure) {
        DialogHelper.error(context,
            message: "Error al cargar mesas", onConfirmed: () {});
      }, (mesas) {
        setState(() {
          mesasLista = mesas;
        });
      });
    } catch (e) {
      debugPrint("Error al obtener mesas");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);

    if (appState.isLoading) {
      return const ShimmerDetalle();
    }

    final producto = _productoActualizado ?? widget.producto;

    return PantallaBase(
      title: producto.nombre,
      onBack: () => Navigator.of(context).pop(),
      onSectionChange: widget.onSectionChange,
      body: _DetalleCompra(
        initialProducto: producto,
        productosDisponibles: productosLista,
        mesasDisponibles: mesasLista,
      ),
    );
  }
}

class _DetalleCompra extends StatefulWidget {
  final ProductoEntity initialProducto;
  final List<ProductoEntity> productosDisponibles;
  final List<MesaEntity> mesasDisponibles;
  const _DetalleCompra({
    required this.initialProducto,
    required this.productosDisponibles,
    required this.mesasDisponibles,
  });

  @override
  State<_DetalleCompra> createState() => _DetalleCompraState();
}

class _DetalleCompraState extends State<_DetalleCompra> {
  final List<CartProduct> _carrito = [];
  bool _aplicaIva = true;
  ProductoEntity? _productoAAgregar;
  MesaEntity? _mesaSeleccionada;

  @override
  void initState() {
    super.initState();
    _carrito.add(CartProduct(producto: widget.initialProducto, cantidad: 1));
  }

  double get _subtotal {
    return _carrito.fold(
        0.0, (acc, item) => acc + (item.producto.precio * item.cantidad));
  }

  double get _iva => _aplicaIva ? _subtotal * 0.15 : 0.0;
  double get _total => _subtotal + _iva;

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
                        onPressed: () {}),
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
