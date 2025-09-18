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

class ProductoDetallePage extends ConsumerStatefulWidget {
  final ProductoEntity producto;

  const ProductoDetallePage({super.key, required this.producto});

  @override
  ConsumerState<ProductoDetallePage> createState() =>
      _ProductoDetallePageState();
}

class _ProductoDetallePageState extends ConsumerState<ProductoDetallePage> {
  ProductoEntity? _productoActualizado;
  late final ProductosRepository _productosRepository;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _productosRepository = ProductosRepositoryImpl(
      ProductosRemoteDataSource(ref: ref),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarProducto();
    });
  }

  Future<void> _cargarProducto() async {
    setState(() => _isLoading = true);

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
          _isLoading = false;
        });
      });
    } catch (_) {
      setState(() {
        _productoActualizado = widget.producto;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
      body: _DetalleCompra(producto: producto),
    );
  }
}

class _DetalleCompra extends StatefulWidget {
  final ProductoEntity producto;
  const _DetalleCompra({required this.producto});

  @override
  State<_DetalleCompra> createState() => _DetalleCompraState();
}

class _DetalleCompraState extends State<_DetalleCompra> {
  int _cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final total = _cantidad * producto.precio;

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
        // Nombre
        Text(
          producto.nombre,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),

        Text(
          "Precio: \$${producto.precio.toStringAsFixed(2)}",
          style: const TextStyle(
            color: ThemeApp.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            IconButton(
              onPressed:
                  _cantidad > 1 ? () => setState(() => _cantidad--) : null,
              icon: const Icon(Icons.remove_circle),
            ),
            Text("$_cantidad", style: const TextStyle(fontSize: 18)),
            IconButton(
              onPressed: () => setState(() => _cantidad++),
              icon: const Icon(Icons.add_circle),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total calculado
        Text(
          "Total: \$${total.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),

        // Botón compra
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: producto.disponible!
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Compra finalizada → ${producto.nombre} x$_cantidad por \$${total.toStringAsFixed(2)}",
                        ),
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.shopping_bag),
            label:
                const Text("Finalizar compra", style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: ResponsiveUtil.isSmall(context)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(producto),
                const SizedBox(height: 16),
                content,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildImage(producto)),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: content),
              ],
            ),
    );
  }

  Widget _buildImage(ProductoEntity producto) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        producto.imagen ?? "",
        width: double.infinity,
        height: ResponsiveUtil.isSmall(context) ? 220 : 350,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[300],
          height: 220,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported, size: 48),
        ),
      ),
    );
  }
}
