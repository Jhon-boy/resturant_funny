// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/formatters.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/sucursal_map_widget.dart';
import 'package:resturant_funny/shared/widgets/dialog_generic_widget.dart';

class CrearSucursal extends ConsumerStatefulWidget {
  final bool isEdit;
  final SucursalEntity? sucursal;

  const CrearSucursal({
    super.key,
    required this.isEdit,
    this.sucursal,
  });

  static Future<SucursalEntity?> show({
    required BuildContext context,
    required bool isEdit,
    SucursalEntity? sucursal,
  }) async {
    return showDialog<SucursalEntity>(
      context: context,
      builder: (context) => CrearSucursal(
        isEdit: isEdit,
        sucursal: sucursal,
      ),
    );
  }

  @override
  ConsumerState<CrearSucursal> createState() => _CrearSucursalState();
}

class _CrearSucursalState extends ConsumerState<CrearSucursal> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _contactoController = TextEditingController();

  late SucursalRepository _sucursalRepository;
  bool _isActiva = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sucursalRepository = SucursalRemoteRepository(
      SucursalRemoteDataSource(ref: ref),
    );

    if (widget.isEdit && widget.sucursal != null) {
      _nombreController.text = widget.sucursal!.nombre;
      _direccionController.text = widget.sucursal!.direccion ?? '';
      _latitudController.text = widget.sucursal!.latitud?.toString() ?? '';
      _longitudController.text = widget.sucursal!.longitud?.toString() ?? '';
      _contactoController.text = widget.sucursal!.contacto ?? '';
      _isActiva = widget.sucursal!.estado ?? true;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = ref.watch(appStateProvider);
    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);

    try {
      final usuario = ref.read(userProvider).user;
      final fechaActual = AppUtils.getFechaActual();
      final usuarioId = usuario?.idUsuario?.toString();

      SucursalEntity sucursalData;

      if (widget.isEdit && widget.sucursal != null) {
        // Actualizar sucursal existente
        final latitud = _latitudController.text.trim().isEmpty
            ? null
            : double.tryParse(_latitudController.text.trim());
        final longitud = _longitudController.text.trim().isEmpty
            ? null
            : double.tryParse(_longitudController.text.trim());

        sucursalData = widget.sucursal!.copyWith(
          nombre: _nombreController.text.trim(),
          direccion: _direccionController.text.trim().isEmpty
              ? null
              : _direccionController.text.trim(),
          latitud: latitud,
          longitud: longitud,
          contacto: _contactoController.text.trim().isEmpty
              ? null
              : _contactoController.text.trim(),
          estado: _isActiva,
          fModificacion: fechaActual,
          userModificacion: usuarioId,
        );

        final result =
            await _sucursalRepository.updateSucursalEntity(sucursalData);
        result.fold(
          (failure) {
            appState.setLoading(false);
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              SnackHelper.show(
                context,
                message: 'Error al actualizar sucursal: ${failure.message}',
                isError: true,
              );
            }
          },
          (sucursalActualizada) {
            appState.setLoading(false);
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              SnackHelper.show(
                context,
                message: 'Sucursal actualizada correctamente',
                isSuccess: true,
              );
              Navigator.of(context).pop(sucursalActualizada);
            }
          },
        );
      } else {
        // Crear nueva sucursal
        final latitud = _latitudController.text.trim().isEmpty
            ? null
            : double.tryParse(_latitudController.text.trim());
        final longitud = _longitudController.text.trim().isEmpty
            ? null
            : double.tryParse(_longitudController.text.trim());

        sucursalData = SucursalEntity(
          nombre: _nombreController.text.trim(),
          direccion: _direccionController.text.trim().isEmpty
              ? null
              : _direccionController.text.trim(),
          latitud: latitud,
          longitud: longitud,
          contacto: _contactoController.text.trim().isEmpty
              ? null
              : _contactoController.text.trim(),
          estado: _isActiva,
          fCreacion: fechaActual,
          usuarioIngreso: usuarioId,
        );

        final result =
            await _sucursalRepository.registerSucursalEntity(sucursalData);
        result.fold(
          (failure) {
            appState.setLoading(false);
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              SnackHelper.show(
                context,
                message: 'Error al crear sucursal: ${failure.message}',
                isError: true,
              );
            }
          },
          (sucursalCreada) {
            appState.setLoading(false);
            setState(() {
              _isLoading = false;
            });
            if (mounted) {
              SnackHelper.show(
                context,
                message: 'Sucursal creada correctamente',
                isSuccess: true,
              );
              Navigator.of(context).pop(sucursalCreada);
            }
          },
        );
      }
    } catch (e) {
      appState.setLoading(false);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        SnackHelper.show(
          context,
          message: 'Error inesperado: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogoPersonalizadoWidget(
      buttonTitle: widget.isEdit ? 'Editar' : 'Crear',
      titulo: widget.isEdit ? 'Editar Sucursal' : 'Crear Sucursal',
      onAceptarPressed: _isLoading ? null : _guardar,
      blockButton: _isLoading,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _nombreController,
                  inputFormatters: [UpperCaseTextFormatter()],
                  enabled: !_isLoading,
                  decoration: ThemeApp.inputDecoration(
                      'Nombre', 'Ingrese el nombre de la sucursal', Icons.store,
                      isRequired: true, fillColor: ThemeApp.white),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    if (value.trim().length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Dirección
                TextFormField(
                  inputFormatters: [UpperCaseTextFormatter()],
                  maxLength: AppConstants.MAX_CARACTERES_DESCRIPCION,
                  controller: _direccionController,
                  enabled: !_isLoading,
                  decoration: ThemeApp.inputDecoration(
                      'Dirección',
                      'Ingrese la dirección de la sucursal (opcional)',
                      Icons.location_on,
                      isRequired: true,
                      fillColor: ThemeApp.white),
                  textCapitalization: TextCapitalization.words,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección es requerida';
                    }
                    if (value.trim().length < 3) {
                      return 'La dirección debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mapa para seleccionar ubicación (latitud/longitud)
                SucursalMapWidget(
                  latitud: double.tryParse(_latitudController.text),
                  longitud: double.tryParse(_longitudController.text),
                  sucursalNombre: _nombreController.text.trim().isEmpty
                      ? null
                      : _nombreController.text.trim(),
                  enableSelection: true,
                  height: 220,
                  onLocationSelected: (lat, lng) {
                    setState(() {
                      _latitudController.text = lat.toStringAsFixed(6);
                      _longitudController.text = lng.toStringAsFixed(6);
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Campo Contacto
                TextFormField(
                  controller: _contactoController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.text,
                  decoration: ThemeApp.inputDecoration(
                    'Contacto',
                    'Ingrese el contacto (opcional)',
                    Icons.phone,
                    isRequired: false,
                    fillColor: ThemeApp.white,
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),

                // Switch Estado
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estado',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isActiva ? 'Activa' : 'Inactiva',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isActiva
                                    ? ThemeApp.success
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isActiva,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _isActiva = value;
                                });
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
