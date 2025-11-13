import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/inventario/presentation/producto_detalle_page.dart';
import 'package:resturant_funny/modules/inventario/presentation/producto_form_page.dart';
import 'package:resturant_funny/modules/inventario/presentation/widgets/producto_admin_card.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/domain/providers/dining_provider.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/main/presentation/widget/no_producto_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key, required this.titulo});
  final String titulo;

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  late final ProductosRepository _productosRepository;
  late final SucursalRepository _sucursalRepository;

  List<SucursalEntity> _sucursales = [];
  SucursalEntity? _selectedSucursal;

  @override
  void initState() {
    super.initState();
    _productosRepository =
        ProductosRepositoryImpl(ProductosRemoteDataSource(ref: ref));
    _sucursalRepository =
        SucursalRemoteRepository(SucursalRemoteDataSource(ref: ref));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    ref.read(appStateProvider.notifier).setLoading(true);

    final sucursalesResult = await _sucursalRepository.getSucursalesEntity();
    sucursalesResult.fold(
      (failure) {
        _handleError(failure.message);
        setState(() {
          _sucursales = [];
          ref.read(appStateProvider.notifier).setLoading(false);
        });
      },
      (sucursales) async {
        final activas = sucursales.where((s) => s.isActiva).toList();
        final selected = _resolveInitialSucursal(activas);

        setState(() {
          _sucursales = activas;
          _selectedSucursal = selected;
        });

        if (selected != null) {
          ref.read(diningProvider.notifier).setSucursal(selected);
        }

        if (selected?.idSucursal != null) {
          await _fetchProductos(selected!.idSucursal!);
        } else {
          ref.read(appStateProvider.notifier).setLoading(false);
        }
      },
    );
  }

  Future<void> _refreshProductos() async {
    final selected = _selectedSucursal;
    if (selected?.idSucursal == null) return;
    await _fetchProductos(selected!.idSucursal!);
  }

  Future<void> _fetchProductos(int idSucursal) async {
    setState(() {
      ref.read(appStateProvider.notifier).setLoading(true);
    });

    final productosResult = await _productosRepository.getProductos(idSucursal);
    productosResult.fold(
      (failure) {
        _handleError(failure.message);
        setState(() {
          ref.read(appStateProvider.notifier).setLoading(false);
        });
      },
      (productos) {
        if (!mounted) return;
        setState(() {
          ref.read(appStateProvider.notifier).setLoading(false);
        });
        ref.read(diningProvider.notifier).setProductos(productos);
      },
    );
  }

  SucursalEntity? _resolveInitialSucursal(List<SucursalEntity> sucursales) {
    if (sucursales.isEmpty) return null;
    final user = ref.read(userProvider).user;
    if (user?.idSucursal != null) {
      try {
        return sucursales.firstWhere((s) => s.idSucursal == user!.idSucursal);
      } catch (_) {
        // Se usará la primera sucursal activa más abajo.
      }
    }
    return sucursales.isNotEmpty ? sucursales.first : null;
  }

  void _mostrarDetalleProducto(ProductoEntity producto) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductoDetallePage(
          producto: producto,
          onEdit: () => _editarProducto(producto),
          onToggleDisponibilidad: () => _handleToggleDisponibilidad(producto),
          onDelete: () => _handleDelete(producto),
        ),
      ),
    );
  }

  Future<void> _editarProducto(ProductoEntity producto) async {
    if (_sucursales.isEmpty) {
      SnackHelper.show(context,
          message: 'No hay sucursales disponibles', isError: true);
      return;
    }

    final resultado = await ProductoFormPage.navigate(
      context: context,
      sucursales: _sucursales.where((s) => s.idSucursal != null).toList(),
      producto: producto,
      titulo: 'Editar producto',
    );

    if (resultado == null || !mounted) return;

    final productos = ref.read(diningProvider).productos;
    final actualizados = productos
        .map((p) => p.idProducto == resultado.idProducto ? resultado : p)
        .toList();
    ref.read(diningProvider.notifier).setProductos(actualizados);

    if (mounted) {
      Navigator.of(context).pop();
      SnackHelper.show(context,
          message: 'Producto actualizado', isSuccess: true);
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    SnackHelper.show(context, message: message, isError: true);
  }

  Future<void> _handleToggleDisponibilidad(ProductoEntity producto) async {
    DialogHelper.confirm(
      context,
      message:
          '¿Está seguro de ${producto.isDisponible ? 'ocultar' : 'mostrar'} el producto ${producto.nombre}?',
      onConfirm: () async {
        if (!mounted) return;
        ref.read(appStateProvider.notifier).setLoading(true);

        final result = await _productosRepository.toggleDisponibilidad(
          producto.idProducto!.toString(),
          disponible: !producto.isDisponible,
        );

        if (!mounted) return;

        result.fold(
          (failure) {
            ref.read(appStateProvider.notifier).setLoading(false);
            DialogHelper.error(context,
                message: failure.message, onConfirmed: () {});
          },
          (productoActualizado) {
            final productos = ref.read(diningProvider).productos;
            final actualizados = productos
                .map((p) => p.idProducto == productoActualizado.idProducto
                    ? productoActualizado
                    : p)
                .toList();
            ref.read(diningProvider.notifier).setProductos(actualizados);

            ref.read(appStateProvider.notifier).setLoading(false);
            SnackHelper.show(context,
                message: productoActualizado.isDisponible
                    ? 'Producto disponible nuevamente'
                    : 'Producto ocultado',
                isSuccess: true);
            Navigator.of(context).pop();
          },
        );
      },
      onCancel: () {},
    );
  }

  Future<void> _handleDelete(ProductoEntity producto) async {
    try {
      DialogHelper.confirm(context,
          message: '¿Está seguro de eliminar el producto ${producto.nombre}?',
          onConfirm: () async {
        final result = await _productosRepository.deleteProducto(
            producto.idProducto!.toString(), ref.read(userProvider).user!);
        result.fold((failure) {
          _handleError(failure.message);
        }, (ok) {
          if (!mounted) return;
          SnackHelper.show(context,
              message: 'Producto eliminado', isSuccess: true);
          Navigator.of(context).pop();
          _refreshProductos();
        });
      }, onCancel: () {});
    } catch (e) {
      _handleError(e.toString());
      debugPrint('Error al eliminar el producto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(appStateProvider.select((state) => state.isLoading));

    return PantallaBase(
      onBack: () => Navigator.of(context).pop(),
      title: widget.titulo,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Seleccione la sucursal',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            CustomDropdown<SucursalEntity>(
              value: _selectedSucursal,
              label: 'Sucursal',
              hint: 'Seleccione una sucursal',
              displayText: (sucursal) => sucursal.nombre,
              items: _sucursales,
              onChanged: (sucursal) {
                if (sucursal == null ||
                    sucursal.idSucursal == _selectedSucursal?.idSucursal) {
                  return;
                }
                setState(() {
                  _selectedSucursal = sucursal;
                });
                ref.read(diningProvider.notifier).setSucursal(sucursal);
                _fetchProductos(sucursal.idSucursal!);
              },
            ),
            const SizedBox(height: 8),
            Text.rich(TextSpan(children: [
              const TextSpan(text: 'Menu de productos de la sucursal: '),
              TextSpan(
                  text: _selectedSucursal?.nombre ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ])),
            const SizedBox(height: 8),
            Expanded(
              child: _ProductosList(
                isLoading: isLoading,
                productos: ref.read(diningProvider).productos,
                onRefresh: _refreshProductos,
                onSelect: _mostrarDetalleProducto,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
                icon: Icons.restaurant_menu_rounded,
                text: 'Registrar Menu',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProductoFormPage(
                            titulo: 'Registrar Menu',
                            sucursales: _sucursales,
                          )));
                })
          ],
        ),
      ),
    );
  }
}

class _ProductosList extends StatelessWidget {
  const _ProductosList({
    required this.isLoading,
    required this.productos,
    required this.onRefresh,
    required this.onSelect,
  });

  final bool isLoading;
  final List<ProductoEntity> productos;
  final Future<void> Function() onRefresh;
  final ValueChanged<ProductoEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    if (isLoading && productos.isEmpty) {
      return ShimmerWidget.list(itemCount: 3);
    }

    return RefreshIndicator(
      color: ThemeApp.primary,
      onRefresh: onRefresh,
      child: productos.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [SizedBox(height: 120), NoProductosWidget()],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = ResponsiveUtil.columnsForGrid(
                  context,
                  minTileWidth: 280,
                  minColumns: 1,
                  maxColumns: 4,
                );

                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.1,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return ProductoAdminCard(
                      producto: producto,
                      onTap: () => onSelect(producto),
                    );
                  },
                );
              },
            ),
    );
  }
}
