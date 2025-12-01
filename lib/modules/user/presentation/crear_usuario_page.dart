// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/mappers/usuario_mapper.dart';
import 'package:resturant_funny/modules/user/domain/repository/usuario_repository.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class CrearUsuarioPage extends ConsumerStatefulWidget {
  final String identificacion;
  final PersonaEntity? persona;
  final String? titulo;
  final List<SucursalEntity> sucursales;

  const CrearUsuarioPage({
    super.key,
    required this.identificacion,
    this.persona,
    this.titulo,
    required this.sucursales,
  });

  /// Método estático para navegar a la página de crear usuario
  static Future<TUsuariEntity?> navigate({
    required BuildContext context,
    required String identificacion,
    PersonaEntity? persona,
    String? titulo,
    required List<SucursalEntity> sucursales,
  }) {
    return Navigator.of(context).push<TUsuariEntity>(
      MaterialPageRoute(
        builder: (context) => CrearUsuarioPage(
          identificacion: identificacion,
          persona: persona,
          titulo: titulo,
          sucursales: sucursales,
        ),
      ),
    );
  }

  @override
  ConsumerState<CrearUsuarioPage> createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends ConsumerState<CrearUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late UsuariosRepository _usuariosRepository;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isTemporal = true;
  SucursalEntity? _sucursalSeleccionada;

  @override
  void initState() {
    super.initState();
    _usuariosRepository = UsuariosRepositoryImpl(
      UsuariosRemoteDataSource(ref: ref),
    );

    // Establecer la primera sucursal activa por defecto
    final sucursalesActivas =
        widget.sucursales.where((s) => s.isActiva).toList();
    if (sucursalesActivas.isNotEmpty) {
      _sucursalSeleccionada = sucursalesActivas.first;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usuarioController.text = '';
      _passwordController.text = '';
      _confirmPasswordController.text = '';
      _usuarioController.text = widget.identificacion;
      _passwordController.text = widget.identificacion;
      setState(() {
        _isTemporal = false;
      });
      DialogHelper.info(context,
          message: '¿Desea auto completar la información del usuario?',
          onConfirmed: () {
        setState(() {
          _isTemporal = true;
          _obscurePassword = false;
          _usuarioController.text = widget.identificacion;
          _passwordController.text = widget.identificacion;
        });
      });
    });
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(userProvider).user;
    if (user == null || user.idSucursal == null) {
      SnackHelper.show(
        context,
        message: 'Usuario no autenticado o sin sucursal asignada',
        isError: true,
      );
      return;
    }
    final appState = ref.watch(appStateProvider);

    if (_sucursalSeleccionada == null) {
      SnackHelper.show(
        context,
        message: 'Por favor seleccione una sucursal',
        isError: true,
      );
      return;
    }

    try {
      appState.setLoading(true);
      final nuevoUsuario = UsuarioMapper.fromFormData(
          identificacion: widget.identificacion,
          user: _usuarioController.text.trim(),
          password: _passwordController.text.trim(),
          isTemporal: _isTemporal,
          idSucursal: _sucursalSeleccionada!.idSucursal);

      final result = await _usuariosRepository.createUsuario(nuevoUsuario);

      result.fold(
        (failure) {
          appState.setLoading(false);
          SnackHelper.show(
            context,
            message: 'Error al crear usuario: ${failure.message}',
            isError: true,
          );
        },
        (usuarioCreado) {
          appState.setLoading(false);
          SnackHelper.show(
            context,
            message: 'Usuario creado correctamente',
            isSuccess: true,
          );
          Navigator.of(context).pop(usuarioCreado);
        },
      );
    } catch (e) {
      appState.setLoading(false);
      SnackHelper.show(
        context,
        message: 'Error inesperado: $e',
        isError: true,
      );
    } finally {
      appState.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personaNombre = widget.persona != null
        ? '${widget.persona!.nombres} ${widget.persona!.apellidos}'
        : widget.identificacion;

    return PantallaBase(
      title: widget.titulo ?? 'Crear Usuario',
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información de la persona
              Card(
                color: ThemeApp.cardColors,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: ThemeApp.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Persona',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  personaNombre,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'ID: ${widget.identificacion}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo Usuario
              TextFormField(
                controller: _usuarioController,
                decoration: ThemeApp.inputDecoration('Nombre de Usuario',
                    'Ingrese el nombre de usuario (opcional)', Icons.person),
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 3) {
                      return 'El nombre de usuario debe tener al menos 3 caracteres';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
                      return 'Solo se permiten letras y números (sin espacios)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingrese la contraseña (opcional)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final trimmedValue = value.trim();
                    if (trimmedValue.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    if (_isTemporal) {
                      return null;
                    }
                    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(trimmedValue)) {
                      return 'Solo se permiten letras y números';
                    }
                    // Verificar que tenga al menos un número
                    if (!RegExp(r'[0-9]').hasMatch(trimmedValue)) {
                      return 'La contraseña debe contener al menos un número';
                    }
                    // Verificar que tenga al menos una letra
                    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmedValue)) {
                      return 'La contraseña debe contener al menos una letra';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Confirmar Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  hintText: 'Confirme la contraseña (opcional)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                validator: (value) {
                  if (_passwordController.text.trim().isNotEmpty) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Debe confirmar la contraseña';
                    }
                    if (value.trim() != _passwordController.text.trim()) {
                      return 'Las contraseñas no coinciden';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 8),
              // Campo Sucursal
              DropdownButtonFormField<SucursalEntity>(
                value: _sucursalSeleccionada,
                decoration: ThemeApp.inputDecoration(
                  'Seleccione la Sucursal',
                  'Seleccione la sucursal',
                  Icons.store,
                ),
                isExpanded: true,
                items: widget.sucursales
                    .where((s) => s.isActiva)
                    .map((sucursal) => DropdownMenuItem<SucursalEntity>(
                          value: sucursal,
                          child: Text(
                            sucursal.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (sucursal) {
                  setState(() {
                    _sucursalSeleccionada = sucursal;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione una sucursal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Row(children: [
                const Text("Usuario Temporal"),
                const SizedBox(width: 8),
                Switch(
                  value: _isTemporal,
                  onChanged: (v) => setState(() => _isTemporal = v),
                ),
              ]),

              const SizedBox(height: 16),
              // Información adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isTemporal
                            ? ' Atención: Este usuario es temporal por lo que el usuario tendra que ser actualizado por el titular al iniciar sesión '
                            : 'Nota: Los campos son opcionales. Si no se proporciona un nombre de usuario o contraseña, el usuario podrá ser creado y los roles pueden asignarse después.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                        colorButton: ThemeApp.textSecondary,
                        text: 'Cancelar',
                        onPressed: () => Navigator.of(context).pop()),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: CustomButton(
                          text: 'Crear Usuario',
                          isLoading: ref.watch(appStateProvider).isLoading,
                          onPressed: () {
                            _crearUsuario();
                          }))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
