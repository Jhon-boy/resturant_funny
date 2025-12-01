import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/providers/dining_provider.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/presentation/widget/no_producto_widget.dart';
import 'package:resturant_funny/modules/main/presentation/widget/producto_card_widget.dart';
import 'package:resturant_funny/modules/main/presentation/widget/producto_carrusel_widget.dart';
import 'package:resturant_funny/shared/widgets/shimer_producto.dart';
import 'package:resturant_funny/modules/ventas/presentation/producto_detalle_venta_page.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';

class InicioPage extends ConsumerStatefulWidget {
  final Function(int)? onSectionChange;

  const InicioPage({super.key, this.onSectionChange});

  @override
  ConsumerState<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends ConsumerState<InicioPage> {
  List<ProductoEntity> _productos = [];
  bool _isLoading = true;
  late final ProductosRepository _productosRepository;

  @override
  void initState() {
    super.initState();
    _productosRepository =
        ProductosRepositoryImpl(ProductosRemoteDataSource(ref: ref));
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);

    final diningContext = ref.read(diningProvider);

    setState(() {
      _productos = diningContext.productosDisponibles;
      _isLoading = false;
    });
  }

  Future<void> _refreshProductos() async {
    setState(() => _isLoading = true);

    final idSucursal =
        ref.read(userProvider.notifier).getUser()?.idSucursal ?? 1;

    final result = await _productosRepository.getProductos(idSucursal);
    result.fold(
      (_) {
        if (mounted) {
          DialogHelper.error(context,
              message: "Error el actualizar los productos", onConfirmed: () {});
        }
      },
      (productos) {
        ref.read(diningProvider.notifier).setProductos(productos);
        if (mounted) {
          setState(() {
            _productos = productos.where((p) => p.isDisponible).toList();
            _isLoading = false;
          });
          _refreshPorciones();
        }
      },
    );
  }

  Future<void> _refreshPorciones() async {
    final idSucursal = SingletonApp.getUser()?.idSucursal ?? 1;
    setState(() => _isLoading = true);
    final result = await _productosRepository.getPorciones(idSucursal);
    result.fold((error) {
      debugPrint("Error al obtener las porciones: ${error.message}");
      setState(() {
        _isLoading = false;
      });
    }, (porciones) {
      ref.read(diningProvider.notifier).setPorciones(porciones);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ShimmerLoader();
    }

    if (_productos.isEmpty) {
      return RefreshIndicator(
        color: ThemeApp.primary,
        onRefresh: _refreshProductos,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: const [
            NoProductosWidget(
              message:
                  'No existen productos para esta sucursal. Por favor, contacte con el administrador.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProductos,
      child: _InicioContent(
        productos: _productos,
        onSectionChange: widget.onSectionChange,
      ),
    );
  }
}

class _InicioContent extends StatelessWidget {
  final List<ProductoEntity> productos;
  final Function(int)? onSectionChange;
  const _InicioContent({
    required this.productos,
    this.onSectionChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos del día',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          ProductoCarouselWidget(
            productos: productos,
            onTap: (p) {
              Navigator.of(context, rootNavigator: false).push(
                MaterialPageRoute(
                  builder: (_) => ProductoDetallePage(
                    producto: p,
                    onSectionChange: onSectionChange,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: Divider(
                  color: ThemeApp.textSecondary,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Mas productos",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ThemeApp.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: ThemeApp.textSecondary,
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productos.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtil.columnsForGrid(
                context,
                minTileWidth: 200,
                minColumns: 2,
                maxColumns: 6,
              ),
              mainAxisSpacing: 10,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final producto = productos[index];
              return ProductoCardWidget(
                producto: producto,
                onTap: () {
                  Navigator.of(context, rootNavigator: false).push(
                    MaterialPageRoute(
                      builder: (_) => ProductoDetallePage(
                        producto: producto,
                        onSectionChange: onSectionChange,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
