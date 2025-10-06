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

class CrearPersonaPage extends ConsumerStatefulWidget {
  final String? titulo;
  final PersonaEntity? personaInicial;
  final bool esEdicion;
  final String? identificacion;

  const CrearPersonaPage({
    super.key,
    this.titulo,
    this.personaInicial,
    this.esEdicion = false,
    this.identificacion,
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

  bool _isLoading = false;

  final List<String> _generos = ['Masculino', 'Femenino', 'Otro'];

  final List<String> _estados = ['ACT', 'INA'];

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
      _generoSeleccionado = persona.genero;
      _tipoIdentificacionSeleccionado = persona.tipoIdentificacion;
      _estadoSeleccionado = persona.estado ?? 'ACTIVO';
    } else if (widget.identificacion != null) {
      _identificacionController.text = widget.identificacion!;
      _tipoIdentificacionSeleccionado = _tipoIdentificaciones[0];
    } else {
      _estadoSeleccionado = 'ACTIVO';
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
        SnackHelper.show(context,
            message: 'Usuario no autenticado', isError: true);
        return;
      }

      final persona = PersonaMapper.fromFormData(
        identificacion: _identificacionController.text,
        nombres: _nombresController.text,
        apellidos: _apellidosController.text,
        fechaNacimiento: _fechaNacimiento,
        genero: _generoSeleccionado,
        correo: _correoController.text,
        telefono: _telefonoController.text,
        direccion: _direccionController.text,
        tipoIdentificacion: _tipoIdentificacionSeleccionado,
        estado: _estadoSeleccionado,
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

  void _onFechaSeleccionada(DateTime? fecha) {
    setState(() {
      _fechaNacimiento = fecha;
    });
  }

  String? _validarIdentificacion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La identificación es obligatoria';
    }
    if (value.trim().length != 10) {
      return 'La identificación debe tener 10 dígitos';
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
      if (AppUtils.isValidPhone(value.trim())) {
        return 'El teléfono no es válido';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: widget.titulo ??
          (widget.esEdicion ? 'Editar Persona' : 'Crear Persona'),
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
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
                decoration: ThemeApp.inputDecoration(
                    'Correo Electrónico', 'correo@ejemplo.com', Icons.email),
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
                  items: _estados,
                  displayText: (item) => item,
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
                      text: widget.esEdicion ? 'Actualizar' : 'Crear Persona',
                      icon: widget.esEdicion ? Icons.edit : Icons.person_add,
                      onPressed: _isLoading ? () {} : () => _guardarPersona(),
                      isLoading: _isLoading,
                      enable: !_isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
