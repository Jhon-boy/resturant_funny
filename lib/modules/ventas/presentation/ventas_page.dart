import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart'; 
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart'; 
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart'; 
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/providers/dining_provider.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart'; 
import 'package:resturant_funny/modules/ventas/presentation/widget/detalle_compra.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class VentaPage extends ConsumerStatefulWidget {
  const VentaPage({super.key});
  @override
  ConsumerState<VentaPage> createState() => _VentaPageState();
}

class _VentaPageState extends ConsumerState<VentaPage> {
  List<ProductoEntity> productosLista = [];
  List<MesaEntity> mesasLista = []; 
  late final MesaRepository _mesaRepository;

  @override
  void initState() {
    super.initState(); 
    _mesaRepository = MesaRepositoryImpl(
      MesasRemoteDataSource(ref: ref),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarProductos();
      _cargarMesas();
    });
  }

  Future<void> _cargarProductos() async {
    final idSucursal = ref.read(userProvider.notifier).getUser()?.idSucursal;
    final result =
        await ref.read(diningProvider.notifier).getProductos(idSucursal!);
    setState(() {
      productosLista = result;
    });
  }

  Future<void> _cargarMesas() async {
    try {
      final idSucursal = ref.read(userProvider.notifier).getUser()?.idSucursal;
      final result = await _mesaRepository.getMesasBySucursal(idSucursal!);
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
    return DetalleCompra(
      initialProducto: null,
      productosDisponibles: productosLista,
      mesasDisponibles: mesasLista,
    );
  }
}
