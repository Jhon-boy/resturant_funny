import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/main/presentation/widget/shimer_producto.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/detalle_compra.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
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
    //Inicializar los repositorios
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
    } finally {
      ref.read(appStateProvider).setProcessLoading(false);
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
      body: DetalleCompra(
        initialProducto: producto,
        productosDisponibles: productosLista,
        mesasDisponibles: mesasLista,
      ),
    );
  }
}
