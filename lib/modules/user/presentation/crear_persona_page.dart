// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/formatters.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/persona_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/mappers/persona_mapper.dart';
import 'package:resturant_funny/modules/user/domain/repository/persona_repository.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/input_search_widget.dart';
import 'package:resturant_funny/shared/widgets/persona_card_widget.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';

class CrearPersonaPage extends ConsumerStatefulWidget {
  final String? titulo;
  final PersonaEntity? personaInicial;
  final bool esEdicion;
  final String? identificacion;
  final bool onlyCreate;

  const CrearPersonaPage({
    super.key,
    this.titulo,
    this.personaInicial,
    this.esEdicion = false,
    this.identificacion,
    this.onlyCreate = false,
  });

  /// Método estático para navegar a la página de crear persona
  static Future<PersonaEntity?> navigate({
    required BuildContext context,
    String? titulo,
    PersonaEntity? personaInicial,
    bool esEdicion = false,
    String? identificacion,
  }) {
    return Navigator.of(context).push<PersonaEntity>(
      MaterialPageRoute(
        builder: (context) => CrearPersonaPage(
          titulo: titulo,
          personaInicial: personaInicial,
          esEdicion: esEdicion,
          identificacion: identificacion,
          onlyCreate: true,
        ),
      ),
    );
  }

  @override
  ConsumerState<CrearPersonaPage> createState() => _CrearPersonaPageState();
}

class _CrearPersonaPageState extends ConsumerState<CrearPersonaPage> {
  final _formKey = GlobalKey<FormState>();
  final _identificacionController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  late PersonasRepository _personasRepository;

  DateTime? _fechaNacimiento;
  String? _generoSeleccionado;
  String? _tipoIdentificacionSeleccionado;
  String? _estadoSeleccionado;
  int _index = 0;
  final List<PersonaEntity> _personas = [];
  bool _haRealizadoBusqueda = false;

  // Para el tab de listar
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  final List<PersonaEntity> _personasListadas = [];
  bool _haRealizadoListado = false;

  bool _isLoading = false;
  final List<String> _botones = [
    'Crear',
    'Gestionar',
    'Listar',
  ];

  final List<String> _generos = [
    'No especificado',
    'Masculino',
    'Femenino',
    'Otro'
  ];

  final List<String> _tipoIdentificaciones = [
    'Cédula',
    'Pasaporte',
    'RUC',
    'Cédula de Identidad'
  ];

  @override
  void initState() {
    super.initState();
    _personasRepository = PersonaRepositoryImpl(
      PersonasRemoteDataSource(ref: ref),
    );
    _inicializarFormulario();
    _index = 0;
  }

  void _inicializarFormulario() {
    if (widget.personaInicial != null) {
      final persona = widget.personaInicial!;
      _identificacionController.text = persona.identificacion;
      _nombresController.text = persona.nombres;
      _apellidosController.text = persona.apellidos;
      _correoController.text = persona.correo ?? '';
      _telefonoController.text = persona.telefono ?? '';
      _direccionController.text = persona.direccion ?? '';
      _fechaNacimiento = persona.fechaNacimiento;
      _generoSeleccionado = AppUtils.mapearGeneroDesdeBD(persona.genero);
      _tipoIdentificacionSeleccionado = persona.tipoIdentificacion;
      _estadoSeleccionado = persona.estado ?? EstadosPersona.ACTIVO.state;
    } else if (widget.identificacion != null) {
      _identificacionController.text = widget.identificacion!;
      _tipoIdentificacionSeleccionado = _tipoIdentificaciones[0];
    } else {
      _estadoSeleccionado = EstadosPersona.ACTIVO.state;
      _tipoIdentificacionSeleccionado = _tipoIdentificaciones[0];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.identificacion != null &&
        _identificacionController.text.isNotEmpty &&
        !AppUtils.validarCedula(widget.identificacion!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackHelper.show(context,
            message: 'La identificación no es válida', isError: true);
      });
    }
  }

  @override
  void dispose() {
    _identificacionController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _guardarPersona() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      ref.read(appStateProvider).setProcessLoading(true);
    });

    try {
      final user = ref.read(userProvider).user;
      if (user == null) {
        setState(() {
          _isLoading = false;
          ref.read(appStateProvider).setProcessLoading(false);
        });
        SnackHelper.show(context,
            message: 'Usuario no autenticado', isError: true);
        return;
      }

      if (widget.esEdicion) {
        // MODO EDICIÓN - Actualizar persona existente
        final identificacion = _identificacionController.text.trim();
        final data = PersonaMapper.toUpdateMap(
          nombres: _nombresController.text,
          apellidos: _apellidosController.text,
          fechaNacimiento: _fechaNacimiento,
          genero: _generoSeleccionado,
          correo: _correoController.text,
          telefono: _telefonoController.text,
          direccion: _direccionController.text,
          tipoIdentificacion: _tipoIdentificacionSeleccionado,
          estado: _estadoSeleccionado,
          userModificacion: user.idUsuario!,
        );

        final result =
            await _personasRepository.updatePersona(identificacion, data);

        result.fold(
          (failure) {
            setState(() {
              _isLoading = false;
              ref.read(appStateProvider).setProcessLoading(false);
            });
            DialogHelper.error(context,
                message: 'Error al actualizar persona: ${failure.message}',
                dismissible: true, onConfirmed: () {
              Navigator.of(context).pop();
            });
          },
          (personaActualizada) {
            setState(() {
              _isLoading = false;
              ref.read(appStateProvider).setProcessLoading(false);
            });
            DialogHelper.success(context,
                message: 'Persona actualizada exitosamente',
                dismissible: true, onConfirmed: () {
              AppUtils.backToHome();
            });
          },
        );
      } else {
        final existePersona = await _personasRepository
            .getPersonaByIdentificacion(_identificacionController.text);
        if (existePersona.isRight()) {
          setState(() {
            _isLoading = false;
            ref.read(appStateProvider).setProcessLoading(false);
          });
          DialogHelper.error(context,
              message:
                  'La persona con identificación ${_identificacionController.text} ya existe',
              dismissible: true,
              onConfirmed: () {});
          return;
        }

        // MODO CREACIÓN - Crear nueva persona
        final persona = PersonaMapper.fromFormData(
          identificacion: _identificacionController.text,
          nombres: _nombresController.text,
          apellidos: _apellidosController.text,
          fechaNacimiento: _fechaNacimiento,
          genero: AppUtils.getGenero(_generoSeleccionado ?? 'No especificado'),
          correo: _correoController.text,
          telefono: _telefonoController.text,
          direccion: _direccionController.text,
          tipoIdentificacion: _tipoIdentificacionSeleccionado,
          estado: _estadoSeleccionado ?? EstadosPersona.ACTIVO.state,
        );
        final result = await _personasRepository.createPersona(persona, user);

        result.fold(
          (failure) {
            setState(() {
              _isLoading = false;
              ref.read(appStateProvider).setProcessLoading(false);
            });
            SnackHelper.show(
              context,
              message: 'Error al crear persona: ${failure.message}',
              isError: true,
            );
          },
          (personaCreada) {
            setState(() {
              _isLoading = false;
              ref.read(appStateProvider).setProcessLoading(false);
            });
            SnackHelper.show(
              context,
              message: 'Persona creada exitosamente',
              isSuccess: true,
            );
            Navigator.of(context).pop(personaCreada);
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        ref.read(appStateProvider).setProcessLoading(false);
      });
      SnackHelper.show(
        context,
        message: 'Error inesperado: $e',
        isError: true,
      );
    }
  }

  Future<void> _listarPersonas() async {
    if (_fechaDesde == null || _fechaHasta == null) {
      SnackHelper.show(context,
          message: 'Debe seleccionar fecha desde y fecha hasta', isError: true);
      return;
    }

    if (_fechaDesde!.isAfter(_fechaHasta!)) {
      SnackHelper.show(context,
          message: 'La fecha desde no puede ser mayor que la fecha hasta',
          isError: true);
      return;
    }

    // Validar que el rango no exceda 31 días
    final diasDiferencia = _fechaHasta!.difference(_fechaDesde!).inDays;
    if (diasDiferencia > 31) {
      SnackHelper.show(context,
          message: 'El rango de fechas no puede exceder 31 días',
          isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _haRealizadoListado = true;
      ref.read(appStateProvider).setProcessLoading(true);
    });

    try {
      final result = await _personasRepository.getAllPersonas(
        fechaDesde: _fechaDesde,
        fechaHasta: _fechaHasta,
        includeDeletes: false,
      );

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _personasListadas.clear();
            ref.read(appStateProvider).setProcessLoading(false);
          });
          DialogHelper.error(context,
              message: 'Error al listar personas: ${failure.message}',
              dismissible: true, onConfirmed: () {
            debugPrint('Error al listar personas: ${failure.message}');
          });
        },
        (personas) {
          setState(() {
            _isLoading = false;
            _personasListadas.clear();
            _personasListadas.addAll(personas);
            ref.read(appStateProvider).setProcessLoading(false);
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        ref.read(appStateProvider).setProcessLoading(false);
      });
      DialogHelper.error(context,
          message: 'Error inesperado: $e', dismissible: true, onConfirmed: () {
        debugPrint('Error inesperado al listar: $e');
      });
    }
  }

  Future<void> _buscarPersona(String identificacion) async {
    final appState = ref.watch(appStateProvider);
    try {
      if (identificacion.isEmpty) {
        setState(() {
          _personas.clear();
          _haRealizadoBusqueda = false;
        });
        return;
      }
      setState(() {
        _haRealizadoBusqueda = true;
      });
      appState.setLoading(true);
      final result =
          await _personasRepository.getPersonaByIdentificacion(identificacion);
      result.fold((failure) {
        setState(() {
          _personas.clear();
        });
        DialogHelper.error(context,
            message: '${_identificacionController.text} : ${failure.message}',
            dismissible: true, onConfirmed: () {
          debugPrint('Error al buscar persona: ${failure.message}');
        });
      }, (persona) {
        setState(() {
          _personas.clear();
          _personas.add(persona);
        });
      });
    } finally {
      appState.setLoading(false);
    }
  }

  void _onFechaSeleccionada(DateTime? fecha) {
    setState(() {
      _fechaNacimiento = fecha;
    });
  }

  String? _validarIdentificacion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La identificación es obligatoria';
    }

    if (_tipoIdentificacionSeleccionado == _tipoIdentificaciones[0] &&
        !AppUtils.validarCedula(value.trim())) {
      return 'La cédula no es válida';
    }

    return null;
  }

  String? _validarNombres(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Los nombres son obligatorios';
    }
    if (value.trim().length < 2) {
      return 'Los nombres deben tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validarApellidos(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Los apellidos son obligatorios';
    }
    if (value.trim().length < 2) {
      return 'Los apellidos deben tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validarCorreo(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!AppUtils.isValidEmail(value.trim())) {
        return 'Ingrese un correo válido';
      }
    }
    return null;
  }

  String? _validarTelefono(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!AppUtils.isValidPhone(value.trim())) {
        return 'El teléfono no es válido';
      }
    }
    return null;
  }

  Future<void> _eliminarPersona(PersonaEntity persona) async {
    final appState = ref.watch(appStateProvider);
    appState.setLoading(true);
    try {
      final user = ref.read(userProvider).user;
      if (user == null) {
        appState.setLoading(false);
        SnackHelper.show(context,
            message: 'Usuario no autenticado', isError: true);
        return;
      }
      if (user.identificacion == persona.identificacion) {
        appState.setLoading(false);
        DialogHelper.info(context,
            message: 'No puede eliminar su propia persona',
            dismissible: true, onConfirmed: () {
          debugPrint('No puede eliminar su propia persona');
        });
        return;
      }

      final result =
          await _personasRepository.deletePersona(persona.identificacion, user);
      result.fold(
        (failure) {
          appState.setLoading(false);
          SnackHelper.show(context,
              message: 'Error al eliminar: ${failure.message}', isError: true);
        },
        (success) {
          appState.setLoading(false);
          setState(() {
            _personas.remove(persona);
            _personasListadas.remove(persona);
          });
          DialogHelper.success(context,
              message: 'Persona eliminada exitosamente',
              dismissible: true, onConfirmed: () {
            if (_index == 2 && _fechaDesde != null && _fechaHasta != null) {
              _listarPersonas();
            } else {
              AppUtils.backToHome();
            }
          });
        },
      );
    } catch (e) {
      appState.setLoading(false);
      DialogHelper.error(context,
          message: 'Error al eliminar: $e', dismissible: true, onConfirmed: () {
        debugPrint('Error al eliminar: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: widget.titulo ??
          (widget.esEdicion ? 'Editar Persona' : 'Crear Persona'),
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            if (!widget.onlyCreate)
              SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_botones.length, (i) {
                      final bool isSelected = _index == i;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            _botones[i],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: ThemeApp.primary,
                          backgroundColor: ThemeApp.inputBorder,
                          onSelected: (_) => setState(() => _index = i),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            if (_index == 0) ...[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Información Básica'),
                    const Divider(),
                    const SizedBox(height: 16),
                    CustomDropdown<String>(
                      value: _tipoIdentificacionSeleccionado,
                      label: 'Tipo de Identificación',
                      hint: 'Seleccione el tipo de identificación',
                      items: _tipoIdentificaciones,
                      displayText: (item) => item,
                      onChanged: (value) {
                        setState(() {
                          _tipoIdentificacionSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    // Identificación
                    TextFormField(
                      controller: _identificacionController,
                      enabled: !widget.esEdicion,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 13,
                      decoration: ThemeApp.inputDecoration(
                          'Identificación', '1234567890', Icons.wallet,
                          isRequired: true),
                      validator: _validarIdentificacion,
                    ),
                    const SizedBox(height: 16),

                    // Nombres
                    TextFormField(
                      controller: _nombresController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 30,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                      decoration: ThemeApp.inputDecoration(
                          'Nombres', 'Nombres', Icons.person,
                          isRequired: true),
                      validator: _validarNombres,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _apellidosController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 30,
                      decoration: ThemeApp.inputDecoration(
                          'Apellidos', 'Apellidos', Icons.person,
                          isRequired: true),
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                      ],
                      validator: _validarApellidos,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Información Adicional'),
                    const Divider(),
                    const SizedBox(height: 16),

                    CalendarWidget(
                      title: 'Fecha de Nacimiento',
                      hint: 'Seleccionar fecha de nacimiento',
                      selectedDate: _fechaNacimiento,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      initialDate: DateTime(2000),
                      icon: Icons.calendar_today,
                      onDateSelected: _onFechaSeleccionada,
                    ),
                    const SizedBox(height: 16),

                    // Género
                    CustomDropdown<String>(
                      value: _generoSeleccionado,
                      label: 'Género',
                      hint: 'Seleccione el género',
                      items: _generos,
                      displayText: (item) => item,
                      onChanged: (value) {
                        setState(() {
                          _generoSeleccionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 30,
                      decoration: ThemeApp.inputDecoration('Correo Electrónico',
                          'correo@ejemplo.com', Icons.email),
                      validator: _validarCorreo,
                    ),
                    const SizedBox(height: 16),

                    // Teléfono
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      decoration: ThemeApp.inputDecoration(
                          'Teléfono', '0987654321', Icons.phone),
                      validator: _validarTelefono,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _direccionController,
                      textCapitalization: TextCapitalization.words,
                      maxLines: 2,
                      maxLength: 100,
                      inputFormatters: [UpperCaseTextFormatter()],
                      decoration: ThemeApp.inputDecoration('Dirección',
                          'Calle principal y secundaria', Icons.location_on),
                    ),
                    const SizedBox(height: 16),
                    if (widget.esEdicion) ...[
                      CustomDropdown<String>(
                        value: _estadoSeleccionado,
                        label: 'Estado',
                        hint: 'Seleccione el estado',
                        items: EstadosPersona.allStates,
                        displayText: (item) => item,
                        subtitleText: (item) =>
                            EstadosPersona.getLabelFromState(item),
                        onChanged: (value) {
                          setState(() {
                            _estadoSeleccionado = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomButton(
                              isLoading: _isLoading,
                              colorButton: ThemeApp.textSecondary,
                              text: 'Cancelar',
                              onPressed: () => Navigator.of(context).pop()),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: CustomButton(
                            text: widget.esEdicion
                                ? 'Actualizar'
                                : 'Crear Persona',
                            icon: widget.esEdicion
                                ? Icons.edit
                                : Icons.person_add,
                            onPressed:
                                _isLoading ? () {} : () => _guardarPersona(),
                            isLoading: _isLoading,
                            enable: !_isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (_index == 1) ...[
              InputSearchWidget(
                label: 'Buscar',
                hint: 'Ej: 0102030405',
                showSuffixButton: false,
                onSubmitted: (value) async {
                  _identificacionController.text = value;
                  _buscarPersona(_identificacionController.text);
                },
                onChanged: (value) {
                  setState(() {
                    _identificacionController.text = value;
                    //  _buscarVentasPorCliente(_identificacionController.text);
                  });
                },
              ),
              const SizedBox(height: 8),
              // Lista de personas encontradas
              if (_personas.isNotEmpty)
                ..._personas.map((persona) {
                  return PersonaCardWidget(
                    persona: persona,
                    onEdit: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (context) => CrearPersonaPage(
                            titulo: 'Editar Persona',
                            personaInicial: persona,
                            esEdicion: true,
                          ),
                        ),
                      )
                          .then((_) {
                        if (_identificacionController.text.isNotEmpty) {
                          _buscarPersona(_identificacionController.text);
                        }
                      });
                    },
                    onDelete: () async {
                      DialogHelper.confirm(context,
                          message: '¿Esta seguro de eliminar este registro',
                          onConfirm: () {
                        _eliminarPersona(persona);
                      }, onCancel: () {
                        debugPrint('Cancelado');
                      });
                    },
                  );
                })
              else if (_personas.isEmpty && _haRealizadoBusqueda)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No se encontraron personas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
            if (_index == 2) ...[
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: CalendarWidget(
                    title: 'Seleccione *',
                    hint: 'Fecha desde',
                    selectedDate: _fechaDesde,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    initialDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    icon: Icons.calendar_today,
                    onDateSelected: (fecha) {
                      if (fecha == null) return;
                      setState(() {
                        _fechaDesde = fecha;
                        if (_fechaHasta != null &&
                            _fechaHasta!.difference(fecha).inDays > 31) {
                          final nuevaFechaHasta =
                              fecha.add(const Duration(days: 31));
                          _fechaHasta = nuevaFechaHasta.isBefore(DateTime.now())
                              ? nuevaFechaHasta
                              : DateTime.now();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CalendarWidget(
                    title: 'Seleccione *',
                    hint: 'Fecha hasta',
                    selectedDate: _fechaHasta,
                    firstDate: _fechaDesde ?? DateTime(2000),
                    lastDate: _fechaDesde != null
                        ? _fechaDesde!
                                .add(const Duration(days: 31))
                                .isBefore(DateTime.now())
                            ? _fechaDesde!.add(const Duration(days: 31))
                            : DateTime.now()
                        : DateTime.now(),
                    initialDate: _fechaDesde != null
                        ? _fechaDesde!
                                .add(const Duration(days: 15))
                                .isBefore(DateTime.now())
                            ? _fechaDesde!.add(const Duration(days: 15))
                            : DateTime.now()
                        : DateTime.now(),
                    icon: Icons.calendar_today,
                    onDateSelected: (fecha) {
                      setState(() {
                        _fechaHasta = fecha;
                      });
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Listar Personas',
                icon: Icons.search,
                onPressed: () {
                  if (_fechaDesde != null && _fechaHasta != null) {
                    _listarPersonas();
                  } else {
                    SnackHelper.show(context,
                        message: 'Debe seleccionar fecha desde y fecha hasta',
                        isError: true);
                  }
                },
                isLoading: _isLoading,
                enable:
                    _fechaDesde != null && _fechaHasta != null && !_isLoading,
              ),
              const SizedBox(height: 16),
              if (_personasListadas.isNotEmpty) ...[
                _buildSectionTitle(
                    'Personas Encontradas (${_personasListadas.length})'),
                const Divider(),
                const SizedBox(height: 8),
                ..._personasListadas.map((persona) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PersonaCardWidget(
                      persona: persona,
                      onEdit: () {
                        Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => CrearPersonaPage(
                              titulo: 'Editar Persona',
                              personaInicial: persona,
                              esEdicion: true,
                            ),
                          ),
                        )
                            .then((_) {
                          if (_fechaDesde != null && _fechaHasta != null) {
                            _listarPersonas();
                          }
                        });
                      },
                      onDelete: () async {
                        DialogHelper.confirm(context,
                            message: '¿Está seguro de eliminar este registro?',
                            onConfirm: () {
                          _eliminarPersona(persona);
                        }, onCancel: () {
                          debugPrint('Cancelado');
                        });
                      },
                    ),
                  );
                })
              ] else if (_personasListadas.isEmpty && _haRealizadoListado)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No se encontraron personas en el rango de fechas seleccionado',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ])),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ThemeApp.apple,
      ),
    );
  }
}
