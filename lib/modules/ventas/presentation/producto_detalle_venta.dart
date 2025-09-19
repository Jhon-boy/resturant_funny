import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/main/presentation/widget/shimer_producto.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/cart_item.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class ProductoDetallePage extends ConsumerStatefulWidget {
  final ProductoEntity producto;

  const ProductoDetallePage({super.key, required this.producto});

  @override
  ConsumerState<ProductoDetallePage> createState() =>
      _ProductoDetallePageState();
}

class _ProductoDetallePageState extends ConsumerState<ProductoDetallePage> {
  ProductoEntity? _productoActualizado;
  List<ProductoEntity> productosLista = [];
  late final ProductosRepository _productosRepository;
  bool _loadingProducto = true;
  bool _loadingProductos = true;

  @override
  void initState() {
    super.initState();
    _productosRepository = ProductosRepositoryImpl(
      ProductosRemoteDataSource(ref: ref),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarProducto();
      _cargarProductos();
    });
  }

  Future<void> _cargarProducto() async {
    setState(() => _loadingProducto = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final result = await _productosRepository
          .getProductById(widget.producto.idProducto.toString());
      result.fold((failure) {
        SnackHelper.show(context,
            message: "Error el cargar la informacion del producto",
            isError: true);
      }, (producto) {
        setState(() {
          _productoActualizado = producto;
          _loadingProducto = false;
        });
      });
    } catch (_) {
      setState(() {
        _productoActualizado = widget.producto;
        _loadingProducto = false;
      });
    }
  }

  Future<void> _cargarProductos() async {
    setState(() => _loadingProductos = true);
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
    } finally {
      setState(() => _loadingProductos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _loadingProducto || _loadingProductos;
    if (isLoading) {
      return const ShimmerDetalle();
    }

    final producto = _productoActualizado;
    if (producto == null) {
      return const Center(child: Text("Producto no disponible"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        backgroundColor: ThemeApp.headerBackground,
        foregroundColor: Colors.white,
      ),
      body: _DetalleCompra(
        initialProducto: producto,
        productosDisponibles: productosLista,
      ),
    );
  }
}

class _DetalleCompra extends StatefulWidget {
  final ProductoEntity initialProducto;
  final List<ProductoEntity> productosDisponibles;
  const _DetalleCompra(
      {required this.initialProducto, required this.productosDisponibles});

  @override
  State<_DetalleCompra> createState() => _DetalleCompraState();
}

class _DetalleCompraState extends State<_DetalleCompra> {
  final List<CartItem> _carrito = [];
  bool _aplicaIva = true;
  ProductoEntity? _productoAAgregar;

  @override
  void initState() {
    super.initState();
    _carrito.add(CartItem(producto: widget.initialProducto, cantidad: 1));
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
        _carrito.add(CartItem(producto: seleccionado, cantidad: 1));
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
        CardSeccion(
          title: "Carrito",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ProductoEntity>(
                      value: _productoAAgregar,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Agregar producto",
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: widget.productosDisponibles
                          .map((p) => DropdownMenuItem<ProductoEntity>(
                                value: p,
                                child: Text(p.nombre,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _productoAAgregar = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _agregarProductoSeleccionado,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(""),
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
                        MiniImagen(producto: producto),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(producto.nombre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text("${producto.precio.toStringAsFixed(2)} c/u",
                                  style: const TextStyle(color: Colors.grey)),
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
        const SizedBox(height: 16),
        CardSeccion(
          title: "Resumen",
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
        ),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: content,
    );
  }
}
