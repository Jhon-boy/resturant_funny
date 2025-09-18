// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/providers/dining_provider.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/main/presentation/menu_route.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  late final ProductosRepository _productosRepository;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _productosRepository = ProductosRepositoryImpl(
      ProductosRemoteDataSource(ref: ref),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final idSucursal =
        ref.read(userProvider.notifier).getUser()?.idSucursal ?? 1;

    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 5));
      setState(() {
        _progress = i / 100;
      });
    }

    final result = await _productosRepository.getProductos(idSucursal);

      result.fold(
      (failure) {
        DialogHelper.error(context,
            message: 'Error al obtener los productos: ${failure.message}',
            onConfirmed: () {});
      },
      (productos) {
        ref.read(diningProvider.notifier).setProductos(productos);
        
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MenuRoute()));
    }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 100,
              color: ThemeApp.baseText,
            ),
            const SizedBox(height: 24),
            Text(
              "Restaurant Funny",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ThemeApp.baseText,
                    fontFamily: ThemeApp.fontFamily,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              "Cargando información...",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ThemeApp.baseText,
                    fontFamily: ThemeApp.fontFamily,
                  ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(ThemeApp.baseText),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text("${(_progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
