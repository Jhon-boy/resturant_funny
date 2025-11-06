// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/mappers/sucursal_mapper.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_generic_widget.dart';

class CrearMesaDialog extends ConsumerStatefulWidget {
  final bool isEdit;
  final MesaEntity? mesa;
  final int idSucursal;

  const CrearMesaDialog({
    super.key,
    required this.isEdit,
    this.mesa,
    required this.idSucursal,
  });

  static Future<MesaEntity?> show({
    required BuildContext context,
    required bool isEdit,
    MesaEntity? mesa,
    required int idSucursal,
  }) async {
    return showDialog<MesaEntity>(
      context: context,
      builder: (context) => CrearMesaDialog(
        isEdit: isEdit,
        mesa: mesa,
        idSucursal: idSucursal,
      ),
    );
  }

  @override
  ConsumerState<CrearMesaDialog> createState() => _CrearMesaDialogState();
}

class _CrearMesaDialogState extends ConsumerState<CrearMesaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();

  late MesaRepository _mesaRepository;
  EstadosPersona? _estadoSeleccionado = EstadosPersona.ACTIVO;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mesaRepository = MesaRepositoryImpl(
      MesasRemoteDataSource(ref: ref),
    );

    if (widget.isEdit && widget.mesa != null) {
      _numeroController.text = widget.mesa!.numero?.toString() ?? '';
      final estadoMesa = widget.mesa!.estado?.toUpperCase();
      _estadoSeleccionado = EstadosPersona.all.firstWhere(
        (e) => e.state.toUpperCase() == estadoMesa?.toUpperCase(),
        orElse: () => EstadosPersona.ACTIVO,
      );
    } else {
      _estadoSeleccionado = EstadosPersona.ACTIVO;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_estadoSeleccionado == null) {
      SnackHelper.show(
        context,
        message: 'Por favor seleccione un estado',
        isError: true,
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = ref.watch(appStateProvider);
    appState.setLoading(true);
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isEdit && widget.mesa != null) {
        await _actualizarMesa();
      } else {
        await _crearMesa();
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

  Future<void> _actualizarMesa() async {
    final appState = ref.watch(appStateProvider);
    final numero = int.parse(_numeroController.text.trim());
    final estado = _estadoSeleccionado ?? EstadosPersona.ACTIVO;
    final data = MesaMapper.updateMesaById(numero, estado);

    final result = await _mesaRepository.updateMesaById(
      widget.mesa!.idMesa.toString(),
      data,
    );

    result.fold(
      (failure) {
        appState.setLoading(false);
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          SnackHelper.show(
            context,
            message: 'Error al actualizar mesa: ${failure.message}',
            isError: true,
          );
        }
      },
      (mesaActualizada) {
        appState.setLoading(false);
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          SnackHelper.show(
            context,
            message: 'Mesa actualizada correctamente',
            isSuccess: true,
          );
          Navigator.of(context).pop(mesaActualizada);
        }
      },
    );
  }

  Future<void> _crearMesa() async {
    final appState = ref.watch(appStateProvider);
    final usuario = ref.read(userProvider).user;
    if (usuario == null) {
      appState.setLoading(false);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        SnackHelper.show(
          context,
          message: 'Error: No se pudo obtener la información del usuario',
          isError: true,
        );
      }
      return;
    }

    final numero = int.parse(_numeroController.text.trim());
    final estado = _estadoSeleccionado ?? EstadosPersona.ACTIVO;
    final nuevaMesa = MesaMapper.toEntity(widget.idSucursal, numero, estado);

    final result = await _mesaRepository.createMesa(nuevaMesa, usuario);
    result.fold(
      (failure) {
        appState.setLoading(false);
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          SnackHelper.show(
            context,
            message: 'Error al crear mesa: ${failure.message}',
            isError: true,
          );
        }
      },
      (mesaCreada) {
        appState.setLoading(false);
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          SnackHelper.show(
            context,
            message: 'Mesa creada correctamente',
            isSuccess: true,
          );
          Navigator.of(context).pop(mesaCreada);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogoPersonalizadoWidget(
        titulo: widget.isEdit ? 'Editar Mesa' : 'Crear Mesa',
        buttonTitle: widget.isEdit ? 'Actualizar' : 'Crear',
        onAceptarPressed: _isLoading ? null : _guardar,
        blockButton: _isLoading,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 8, right: 8, top: 15, bottom: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo Número
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: widget.idSucursal.toString()),
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 3,
                    decoration: ThemeApp.inputDecoration(
                      'Sucursal Destino',
                      'Sucursal',
                      Icons.store,
                      fillColor: ThemeApp.cardColors,
                    ),
                    validator: (value) {
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo Número
                  TextFormField(
                    autocorrect: true,
                    controller: _numeroController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    maxLength: 3,
                    decoration: ThemeApp.inputDecoration(
                      'Número de Mesa',
                      'Ingrese el número de la mesa',
                      Icons.table_restaurant,
                      fillColor: ThemeApp.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El número de mesa es requerido';
                      }
                      final numero = int.tryParse(value.trim());
                      if (numero == null) {
                        return 'Debe ingresar un número válido';
                      }
                      if (numero <= 0) {
                        return 'El número debe ser mayor a 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Estado
                  IgnorePointer(
                    ignoring: _isLoading,
                    child: Opacity(
                      opacity: _isLoading ? 0.6 : 1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  'Estado',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomDropdown<EstadosPersona>(
                            value: _estadoSeleccionado,
                            label: 'Estado',
                            hint: 'Seleccione el estado de la mesa',
                            items: EstadosPersona.all,
                            displayText: (estado) => estado.label,
                            subtitleText: (estado) {
                              return estado.state;
                            },
                            icon: Icons.info,
                            enabled: !_isLoading,
                            onChanged: (estado) {
                              if (estado != null) {
                                setState(() {
                                  _estadoSeleccionado = estado;
                                });
                              }
                            },
                          ),
                          if (_estadoSeleccionado == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0, left: 8.0),
                              child: Text(
                                'Por favor seleccione un estado',
                                style: TextStyle(
                                  color: ThemeApp.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
