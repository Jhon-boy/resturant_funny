import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/core/services/enhanced_auth_service.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';

class ProductoRegistroPage extends ConsumerStatefulWidget {
  const ProductoRegistroPage({super.key});

  @override
  ConsumerState<ProductoRegistroPage> createState() =>
      _ProductoRegistroPageState();
}

class _ProductoRegistroPageState extends ConsumerState<ProductoRegistroPage> {
  final _formKey = GlobalKey<FormState>();

  late final ProductosRepository _productosRepository;
  late final SucursalRemoteRepository _sucursalRepository;

  bool _loading = false;
  List<SucursalEntity> _sucursales = [];
  SucursalEntity? _sucursalSeleccionada;

  // Campos
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _categoriaCtrl = TextEditingController();
  final TextEditingController _imagenCtrl = TextEditingController();
  bool _disponible = true;

  @override
  void initState() {
    super.initState();
    _productosRepository =
        ProductosRepositoryImpl(ProductosRemoteDataSource(ref: ref));
    _sucursalRepository =
        SucursalRemoteRepository(SucursalRemoteDataSource(ref: ref));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarSucursales();
    });
  }

  Future<void> _cargarSucursales() async {
    setState(() => _loading = true);
    final result = await _sucursalRepository.getSucursalesEntity();
    result.fold((failure) {
      SnackHelper.show(context, message: failure.message, isError: true);
    }, (data) {
      setState(() {
        _sucursales = data.where((s) => s.isActiva).toList();
        if (_sucursales.isNotEmpty) {
          _sucursalSeleccionada = _sucursales.first;
        }
      });
    });
    setState(() => _loading = false);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sucursalSeleccionada == null) {
      SnackHelper.show(context,
          message: 'Seleccione una sucursal', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final double precio = double.parse(_precioCtrl.text.replaceAll(',', '.'));
      final producto = ProductoEntity(
        idSucursal: _sucursalSeleccionada!.idSucursal!,
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        precio: precio,
        categoria: _categoriaCtrl.text.trim(),
        imagen:
            _imagenCtrl.text.trim().isEmpty ? null : _imagenCtrl.text.trim(),
        disponible: _disponible,
        estado: 'ACTIVO',
        fCreacion: DateTime.now(),
        usuarioIngreso: EnhancedAuthService.currentUser?.usuario,
      );

      final UserModel? user = EnhancedAuthService.currentUser;
      final result = await _productosRepository.createProducto(producto, user!);

      result.fold((failure) {
        SnackHelper.show(context, message: failure.message, isError: true);
      }, (ok) {
        SnackHelper.show(context, message: 'Producto registrado');
        Navigator.of(context).pop(ok);
      });
    } catch (e) {
      SnackHelper.show(context, message: 'Error: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _categoriaCtrl.dispose();
    _imagenCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar producto'),
        backgroundColor: ThemeApp.headerBackground,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<SucursalEntity>(
                        value: _sucursalSeleccionada,
                        items: _sucursales
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.nombre),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _sucursalSeleccionada = v),
                        decoration: const InputDecoration(
                          labelText: 'Sucursal',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null ? 'Seleccione sucursal' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descripcionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _precioCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Precio',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          final parsed =
                              double.tryParse(v.replaceAll(',', '.'));
                          if (parsed == null || parsed < 0)
                            return 'Ingrese un precio válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _categoriaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _imagenCtrl,
                        decoration: const InputDecoration(
                          labelText: 'URL Imagen (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        value: _disponible,
                        onChanged: (v) => setState(() => _disponible = v),
                        title: const Text('Disponible'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _guardar,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
