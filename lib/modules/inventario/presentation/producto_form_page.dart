// ignore: unnecessary_import
// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/core/utils/formatters.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/images/datasource/images_datasorce.dart';
import 'package:resturant_funny/modules/images/repository/images_repository.dart';
import 'package:resturant_funny/modules/inventario/domain/mappers/producto_mappers.dart';
import 'package:resturant_funny/modules/inventario/presentation/widgets/imagen_picker.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/productos_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';
import 'package:resturant_funny/modules/main/domain/providers/dining_provider.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/enums/categorias_producto.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class ProductoFormPage extends ConsumerStatefulWidget {
  const ProductoFormPage({
    super.key,
    required this.sucursales,
    this.producto,
    this.titulo,
  });

  final List<SucursalEntity> sucursales;
  final ProductoEntity? producto;
  final String? titulo;

  bool get esEdicion => producto != null;

  static Future<ProductoEntity?> navigate({
    required BuildContext context,
    required List<SucursalEntity> sucursales,
    ProductoEntity? producto,
    String? titulo,
  }) {
    return Navigator.of(context).push<ProductoEntity>(
      MaterialPageRoute(
        builder: (_) => ProductoFormPage(
          sucursales: sucursales,
          producto: producto,
          titulo: titulo,
        ),
      ),
    );
  }

  @override
  ConsumerState<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends ConsumerState<ProductoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _precioCtrl;
  late bool _disponible;
  late int _idSucursalSeleccionada;
  late String _categoriaSeleccionada;

  late final ProductosRepository _productosRepository;
  late final ImagesRepository _imagesRepository;

  Uint8List? _imagenSeleccionada;
  String? _imagenUrl;
  String? _imagenOriginalUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    resetStado(widget.producto);
    _productosRepository =
        ProductosRepositoryImpl(ProductosRemoteDataSource(ref: ref));
    _imagesRepository = const ImagesDataSource();
  }

  limpiarFormulario() {
    _nombreCtrl.clear();
    _descripcionCtrl.clear();
    _precioCtrl.clear();
    _imagenSeleccionada = null;
    _imagenUrl = null;
    _imagenOriginalUrl = null;
    _disponible = true;
  }

  resetStado(ProductoEntity? producto) {
    _nombreCtrl = TextEditingController(text: producto?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: producto?.descripcion ?? '');
    _precioCtrl = TextEditingController(
      text: producto != null ? producto.precio.toStringAsFixed(2) : '',
    );
    _imagenUrl = producto?.imagen;
    _imagenOriginalUrl = _imagenUrl;
    _disponible = producto?.isDisponible ?? true;
    _idSucursalSeleccionada = producto?.idSucursal ??
        (widget.sucursales
                .firstWhere(
                  (s) => s.idSucursal != null,
                  orElse: () => widget.sucursales.isNotEmpty
                      ? widget.sucursales.first
                      : SucursalEntity(nombre: 'Sin sucursales', idSucursal: 0),
                )
                .idSucursal ??
            0);
    final categorias = ProductosCategorias.all;
    final categoriaProducto = producto?.categoria;
    if (categoriaProducto != null &&
        categorias.any((c) => c.code == categoriaProducto)) {
      _categoriaSeleccionada = categoriaProducto;
    } else {
      _categoriaSeleccionada = categorias
          .firstWhere((c) => c.code == 'PRODUCTO',
              orElse: () => categorias.first)
          .code;
    }
  }

  Future<void> _seleccionarImagen() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _imagenSeleccionada = bytes;
        _imagenUrl = null;
      });
    } catch (e) {
      SnackHelper.show(context,
          message: 'No se pudo seleccionar la imagen', isError: true);
    }
  }

  void _limpiarImagen() {
    setState(() {
      _imagenSeleccionada = null;
      _imagenUrl = null;
    });
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idSucursalSeleccionada == 0) {
      SnackHelper.show(context,
          message: 'Selecciona la sucursal del producto', isError: true);
      return;
    }

    final price = double.parse(_precioCtrl.text.replaceAll(',', '.'));

    ref.read(appStateProvider.notifier).setLoading(true);

    final nombre = _nombreCtrl.text.trim();
    final descripcion = _descripcionCtrl.text.trim();
    final categoria = _categoriaSeleccionada;

    final bool esEdicion = widget.esEdicion;
    final bool hayNuevaImagen = _imagenSeleccionada != null;
    final bool imagenEliminada = esEdicion &&
        !hayNuevaImagen &&
        _imagenOriginalUrl != null &&
        _imagenUrl == null;

    String? imageUrl;
    if (_precioCtrl.text.trim().isEmpty ||
        double.parse(_precioCtrl.text.trim()) <= 0) {
      SnackHelper.show(context,
          message: 'El precio debe ser mayor a 0', isError: true);
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }
    if (_imagenSeleccionada == null) {
      DialogHelper.error(context,
          message: 'Selecciona una imagen para el producto',
          onConfirmed: () {});
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    if (hayNuevaImagen) {
      try {
        final path =
            'sucursal/$_idSucursalSeleccionada/${DateTime.now().millisecondsSinceEpoch}.jpg';

        final uploadResult = await _imagesRepository.uploadFile(
          path: path,
          bytes: _imagenSeleccionada!,
          bucket: 'imagenes',
          contentType: 'image/jpeg',
        );

        Failure? uploadFailure;
        uploadResult.fold((failure) => uploadFailure = failure, (_) {});

        if (uploadFailure != null) {
          throw Exception(uploadFailure!.message);
        }

        final publicUrlResult = await _imagesRepository.getPublicUrl(
          path: path,
          bucket: 'imagenes',
        );

        publicUrlResult.fold(
          (failure) {
            debugPrint('Error: ${failure.message}');
            throw Exception(failure.message);
          },
          (url) => imageUrl = url,
        );
        _imagenOriginalUrl = imageUrl;
      } catch (e) {
        debugPrint('Error: $e');
        if (!mounted) return;
        ref.read(appStateProvider.notifier).setLoading(false);
        SnackHelper.show(context,
            message: 'Error subiendo la imagen: $e', isError: true);
        return;
      }
    } else if (imagenEliminada) {
      imageUrl = null;
    } else {
      imageUrl = _imagenOriginalUrl;
    }

    if (widget.esEdicion) {
      await _actualizarProducto(
        nombre: nombre,
        descripcion: descripcion,
        precio: price,
        categoria: categoria,
        imagen: imageUrl,
      );
    } else {
      await _crearProducto(
        nombre: nombre,
        descripcion: descripcion,
        precio: price,
        categoria: categoria,
        imagen: imageUrl,
      );
    }
  }

  Future<void> _crearProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
    String? imagen,
  }) async {
    final user = ref.read(userProvider).user;
    if (user == null) {
      SnackHelper.show(context,
          message: 'No se encontró la sesión del usuario', isError: true);
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    final nuevoProducto = ProductoEntity(
      idSucursal: _idSucursalSeleccionada,
      nombre: nombre,
      descripcion: descripcion,
      precio: precio,
      categoria: categoria,
      imagen: imagen,
      disponible: _disponible,
      usuarioIngreso: user.usuario,
      estado: EstadosPersona.ACTIVO.state,
    );

    final result =
        await _productosRepository.createProducto(nuevoProducto, user);
    if (!mounted) {
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    result.fold(
      (failure) {
        ref.read(appStateProvider.notifier).setLoading(false);
        SnackHelper.show(context,
            message: 'No se pudo guardar: ${failure.message}', isError: true);
      },
      (productoCreado) {
        final diningState = ref.read(diningProvider);
        final notifier = ref.read(diningProvider.notifier);
        final int? sucursalActual = diningState.sucursal.idSucursal;
        if (sucursalActual == null ||
            sucursalActual == productoCreado.idSucursal) {
          final productos = List<ProductoEntity>.from(diningState.productos);
          final index = productos
              .indexWhere((p) => p.idProducto == productoCreado.idProducto);
          if (index == -1) {
            notifier.agregarProducto(productoCreado);
          } else {
            productos[index] = productoCreado;
            notifier.setProductos(productos);
          }
        }
        ref.read(appStateProvider.notifier).setLoading(false);
        limpiarFormulario();
        DialogHelper.success(context,
            message: 'Producto registrado correctamente', onConfirmed: () {
          Navigator.of(context).pop(productoCreado);
        });
      },
    );
  }

  Future<void> _actualizarProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
    String? imagen,
  }) async {
    final producto = widget.producto;
    if (producto?.idProducto == null) {
      SnackHelper.show(context,
          message: 'Producto no válido para edición', isError: true);
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    final user = ref.read(userProvider).user;
    if (precio <= 0) {
      SnackHelper.show(context,
          message: 'El precio debe ser mayor a 0', isError: true);
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }
    if (user == null) {
      SnackHelper.show(context,
          message: 'No se encontró la sesión del usuario', isError: true);
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    final data = ProductoMappers.toUpdateJson(
        nombre,
        descripcion,
        precio,
        imagen,
        categoria,
        _disponible,
        _idSucursalSeleccionada,
        user.idUsuario!);

    final result = await _productosRepository.updateProductoById(
      producto!.idProducto!.toString(),
      data,
    );

    if (!mounted) {
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    result.fold(
      (failure) {
        ref.read(appStateProvider.notifier).setLoading(false);
        SnackHelper.show(context,
            message: 'No se pudo actualizar: ${failure.message}',
            isError: true);
      },
      (productoActualizado) {
        ref.read(appStateProvider.notifier).setLoading(false);
        SnackHelper.show(context,
            message: 'Producto actualizado correctamente', isSuccess: true);
        Navigator.of(context).pop(productoActualizado);
      },
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titulo = widget.titulo ??
        (widget.esEdicion ? 'Editar producto' : 'Registrar producto');

    return PantallaBase(
      title: titulo,
      onBack: () => Navigator.of(context).pop(),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Card(
          shadowColor: Colors.black.withOpacity(0.05),
          elevation: 10,
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImagenPicker(
                    imagenBytes: _imagenSeleccionada,
                    imagenUrl: _imagenUrl,
                    onPick: _seleccionarImagen,
                    onClear: _limpiarImagen,
                  ),
                  const Divider(height: 1, color: ThemeApp.inputBorder),
                  const SizedBox(height: 16),
                  _buildTextField(
                    icon: Icons.menu,
                    controller: _nombreCtrl,
                    label: 'Nombre del producto',
                    maxLength: AppConstants.MAX_CARACTERES_TITULOS,
                    inputFormatters: [SentenceCaseTextFormatter()],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre del producto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    icon: Icons.description,
                    controller: _descripcionCtrl,
                    label: 'Descripción',
                    inputFormatters: [SentenceCaseTextFormatter()],
                    maxLength: AppConstants.MAX_CARACTERES_DESCRIPCION,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Describe el producto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    icon: Icons.attach_money,
                    controller: _precioCtrl,
                    label: 'Precio',
                    maxLength: 5,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      CurrencyTextFormatter(),
                    ],
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          double.parse(value.replaceAll(',', '.')) <= 0) {
                        return 'Ingresa el precio';
                      }
                      final parsed =
                          double.tryParse(value.replaceAll(',', '.'));
                      if (parsed == null) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona la categoría',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeApp.inputBorder),
                        ),
                        child: CustomDropdown<String>(
                          value: _categoriaSeleccionada,
                          label: 'Categoría',
                          hint: 'Selecciona la categoría',
                          items: ProductosCategorias.all
                              .map((categoria) => categoria.code)
                              .toList(),
                          displayText: (categoria) => categoria,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _categoriaSeleccionada = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona la sucursal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomDropdown<SucursalEntity>(
                        value: widget.sucursales.firstWhere(
                          (s) => s.idSucursal == _idSucursalSeleccionada,
                          orElse: () => widget.sucursales.first,
                        ),
                        items: widget.sucursales,
                        label: 'Sucursal',
                        hint: 'Selecciona la sucursal',
                        displayText: (s) => s.nombre,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() =>
                              _idSucursalSeleccionada = value.idSucursal!);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _disponible,
                    onChanged: (value) {
                      setState(() => _disponible = value);
                    },
                    title: const Text('Disponible para la venta'),
                    activeColor: ThemeApp.success,
                    inactiveTrackColor: ThemeApp.error.withOpacity(0.1),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: widget.esEdicion
                        ? 'Actualizar producto'
                        : 'Guardar producto',
                    onPressed: _guardarProducto,
                    icon: Icons.save_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required TextEditingController controller,
    required String label,
    required maxLength,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: ThemeApp.inputDecoration(label, label, icon,
          isRequired: true, fillColor: ThemeApp.background),
    );
  }
}
