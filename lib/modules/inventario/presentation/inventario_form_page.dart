// ignore: unnecessary_import
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/formatters.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/inventario/data/datasource/inventario_data_source.dart';
import 'package:resturant_funny/modules/inventario/data/repository/inventario_repository_impl.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/modules/inventario/domain/mappers/inventario_mapper.dart';
import 'package:resturant_funny/modules/inventario/domain/repository/inventario_repository.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/enums/categorias_producto.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class InventarioFormPage extends ConsumerStatefulWidget {
  const InventarioFormPage({
    super.key,
    required this.sucursales,
    this.inventario,
    this.titulo,
  });

  final List<SucursalEntity> sucursales;
  final InventarioEntity? inventario;
  final String? titulo;

  bool get esEdicion => inventario != null;

  static Future<InventarioEntity?> navigate({
    required BuildContext context,
    required List<SucursalEntity> sucursales,
    InventarioEntity? inventario,
    String? titulo,
  }) {
    return Navigator.of(context).push<InventarioEntity>(
      MaterialPageRoute(
        builder: (_) => InventarioFormPage(
          sucursales: sucursales,
          inventario: inventario,
          titulo: titulo,
        ),
      ),
    );
  }

  @override
  ConsumerState<InventarioFormPage> createState() => _InventarioFormPageState();
}

class _InventarioFormPageState extends ConsumerState<InventarioFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _categoriaCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _precioCtrl;

  late int _idSucursalSeleccionada;

  late final InventarioRepository _inventarioRepository;

  @override
  void initState() {
    super.initState();
    resetStado(widget.inventario);
    _inventarioRepository = InventarioRepositoryImpl(
      InventarioRemoteDataSource(ref: ref),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _categoriaCtrl.dispose();
    _stockCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  void limpiarFormulario() {
    _nombreCtrl.clear();
    _descripcionCtrl.clear();
    _categoriaCtrl.clear();
    _stockCtrl.clear();
    _precioCtrl.clear();
  }

  void resetStado(InventarioEntity? inventario) {
    _nombreCtrl = TextEditingController(text: inventario?.nombre ?? '');
    _descripcionCtrl =
        TextEditingController(text: inventario?.descripcion ?? '');
    _categoriaCtrl = TextEditingController(text: inventario?.categoria ?? '');
    _stockCtrl = TextEditingController(
        text: inventario?.stock != null ? inventario!.stock.toString() : '');
    _precioCtrl = TextEditingController(
      text: inventario?.precioUnitario != null
          ? inventario!.precioUnitario!.toStringAsFixed(2)
          : '',
    );
    _idSucursalSeleccionada = inventario?.idSucursal ??
        (widget.sucursales
                .firstWhere(
                  (s) => s.idSucursal != null,
                  orElse: () => widget.sucursales.isNotEmpty
                      ? widget.sucursales.first
                      : SucursalEntity(nombre: 'Sin sucursales', idSucursal: 0),
                )
                .idSucursal ??
            0);
  }

  Future<void> _guardarInventario() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idSucursalSeleccionada == 0) {
      SnackHelper.show(context,
          message: 'Selecciona la sucursal del inventario', isError: true);
      return;
    }

    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;
    final precio =
        double.tryParse(_precioCtrl.text.trim().replaceAll(',', '.')) ?? 0.0;

    if (precio < 1) {
      SnackHelper.show(context,
          message: 'El precio debe ser mayor a 0', isError: true);
      return;
    }

    ref.read(appStateProvider.notifier).setLoading(true);

    final nombre = _nombreCtrl.text.trim();
    final descripcion = _descripcionCtrl.text.trim();
    final categoria = _categoriaCtrl.text.trim();

    if (widget.esEdicion) {
      await _actualizarInventario(
        nombre: nombre,
        descripcion: descripcion,
        categoria: categoria,
        stock: stock,
        precio: precio,
      );
    } else {
      await _crearInventario(
        nombre: nombre,
        descripcion: descripcion,
        categoria: categoria,
        stock: stock,
        precio: precio,
      );
    }
  }

  Future<void> _crearInventario({
    required String nombre,
    required String descripcion,
    required String categoria,
    required int stock,
    required double precio,
  }) async {
    final user = ref.read(userProvider).user;
    if (user == null) {
      SnackHelper.show(context,
          message: 'No se encontró la sesión del usuario', isError: true);
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    final nuevoInventario = InventarioMapper.createInventario(
        _idSucursalSeleccionada,
        nombre,
        descripcion,
        categoria,
        stock,
        precio,
        user.idUsuario?.toString() ?? user.usuario ?? 'Admin');
    final result =
        await _inventarioRepository.createInventario(nuevoInventario, user);
    if (!mounted) {
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    result.fold(
      (failure) {
        ref.read(appStateProvider.notifier).setLoading(false);
        DialogHelper.error(context,
            message: 'No se pudo guardar: ${failure.message}', onConfirmed: () {
          // Navigator.of(context).pop();
        });
      },
      (inventarioCreado) {
        ref.read(appStateProvider.notifier).setLoading(false);
        limpiarFormulario();
        DialogHelper.success(context,
            message: 'Inventario registrado correctamente', onConfirmed: () {
          Navigator.of(context).pop(inventarioCreado);
        });
      },
    );
  }

  Future<void> _actualizarInventario({
    required String nombre,
    required String descripcion,
    required String categoria,
    required int stock,
    required double precio,
  }) async {
    final inventario = widget.inventario;
    if (inventario?.idInventario == null) {
      SnackHelper.show(context,
          message: 'Inventario no válido para edición', isError: true);
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

    final data = InventarioMapper.updateInventario(
        nombre,
        descripcion,
        categoria,
        stock,
        precio,
        user.idUsuario?.toString() ?? user.usuario ?? 'Admin',
        _idSucursalSeleccionada);

    final result = await _inventarioRepository.updateInventario(
      inventario!.idInventario!,
      data,
    );

    if (!mounted) {
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    result.fold(
      (failure) {
        ref.read(appStateProvider.notifier).setLoading(false);
        DialogHelper.error(context,
            message: 'No se pudo actualizar: ${failure.message}',
            onConfirmed: () {
          // Navigator.of(context).pop();
        });
      },
      (inventarioActualizado) {
        ref.read(appStateProvider.notifier).setLoading(false);
        DialogHelper.success(context,
            message: 'Inventario actualizado correctamente', onConfirmed: () {
          limpiarFormulario();
          Navigator.of(context).pop(inventarioActualizado);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
        title: widget.titulo ??
            (widget.esEdicion ? 'Editar Inventario' : 'Registrar Inventario'),
        onBack: () => Navigator.of(context).pop(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              //padding: const EdgeInsets.all(16),
              children: [
                CustomDropdown<SucursalEntity>(
                  value: widget.sucursales.firstWhere(
                    (s) => s.idSucursal == _idSucursalSeleccionada,
                    orElse: () => widget.sucursales.first,
                  ),
                  label: 'Sucursal',
                  hint: 'Seleccione una sucursal',
                  displayText: (sucursal) => sucursal.nombre,
                  items: widget.sucursales,
                  onChanged: (sucursal) {
                    if (sucursal?.idSucursal != null) {
                      setState(() {
                        _idSucursalSeleccionada = sucursal!.idSucursal!;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: ThemeApp.inputDecoration(
                    'Nombre',
                    'Ingrese el nombre del inventario',
                    Icons.label,
                    isRequired: true,
                  ),
                  inputFormatters: [SentenceCaseTextFormatter()],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionCtrl,
                  decoration: ThemeApp.inputDecoration(
                    'Descripción',
                    'Ingrese la descripción (opcional)',
                    Icons.description,
                  ),
                  maxLines: 3,
                  inputFormatters: [SentenceCaseTextFormatter()],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categoría'),
                    const SizedBox(height: 8),
                    CustomDropdown<String>(
                      value: _categoriaCtrl.text.isEmpty ||
                              !ProductosCategorias.allCodes
                                  .contains(_categoriaCtrl.text)
                          ? null
                          : _categoriaCtrl.text,
                      label: 'Categoría',
                      hint: 'Seleccione una categoría',
                      items: ProductosCategorias.allCodes,
                      displayText: (categoria) => categoria,
                      onChanged: (categoria) {
                        setState(() {
                          _categoriaCtrl.text = categoria ?? '';
                        });
                      },
                      enabled: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockCtrl,
                  decoration: ThemeApp.inputDecoration(
                    'Stock',
                    'Ingrese la cantidad en stock',
                    Icons.inventory,
                    isRequired: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    debugPrint('value: $value');
                    if (value == null || value.trim().isEmpty) {
                      return 'El stock es requerido';
                    }
                    final stock = int.tryParse(value);
                    debugPrint('stock: $stock');
                    if (stock == null || stock < 1) {
                      return 'El stock debe ser un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precioCtrl,
                  decoration: ThemeApp.inputDecoration(
                    'Precio Unitario',
                    'Ingrese el precio unitario',
                    Icons.attach_money,
                    isRequired: true,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El precio es requerido';
                    }
                    final precio = double.tryParse(value.replaceAll(',', '.'));
                    if (precio == null || precio <= 0) {
                      return 'El precio debe ser mayor a 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  icon: Icons.save,
                  text: widget.esEdicion ? 'Actualizar' : 'Guardar',
                  onPressed: _guardarInventario,
                ),
              ],
            ),
          ),
        ));
  }
}
