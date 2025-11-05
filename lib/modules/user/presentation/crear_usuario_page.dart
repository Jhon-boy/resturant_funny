// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/repository/usuario_repository.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';

class CrearUsuarioPage extends ConsumerStatefulWidget {
  final String identificacion;
  final PersonaEntity? persona;
  final String? titulo;

  const CrearUsuarioPage({
    super.key,
    required this.identificacion,
    this.persona,
    this.titulo,
  });

  /// Método estático para navegar a la página de crear usuario
  static Future<TUsuariEntity?> navigate({
    required BuildContext context,
    required String identificacion,
    PersonaEntity? persona,
    String? titulo,
  }) {
    return Navigator.of(context).push<TUsuariEntity>(
      MaterialPageRoute(
        builder: (context) => CrearUsuarioPage(
          identificacion: identificacion,
          persona: persona,
          titulo: titulo,
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usuariosRepository = UsuariosRepositoryImpl(
      UsuariosRemoteDataSource(ref: ref),
    );
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear el usuario
      final nuevoUsuario = TUsuariEntity(
        idUsuario: 0, // Se generará automáticamente por la BD
        idSucursal: user.idSucursal!,
        identificacion: widget.identificacion,
        usuario: _usuarioController.text.trim().isEmpty
            ? null
            : _usuarioController.text.trim(),
        password: _passwordController.text.trim().isEmpty
            ? null
            : _passwordController.text.trim(),
        temporal: false,
        fCreacion: AppUtils.getFechaActual(),
        usuarioIngreso: user.idUsuario?.toString(),
      );

      final result = await _usuariosRepository.createUsuario(nuevoUsuario);

      result.fold(
        (failure) {
          SnackHelper.show(
            context,
            message: 'Error al crear usuario: ${failure.message}',
            isError: true,
          );
        },
        (usuarioCreado) {
          SnackHelper.show(
            context,
            message: 'Usuario creado correctamente',
            isSuccess: true,
          );
          Navigator.of(context).pop(usuarioCreado);
        },
      );
    } catch (e) {
      SnackHelper.show(
        context,
        message: 'Error inesperado: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                elevation: 2,
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
                          Icon(
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
              const SizedBox(height: 24),

              // Campo Usuario
              TextFormField(
                controller: _usuarioController,
                decoration: InputDecoration(
                  labelText: 'Nombre de Usuario',
                  hintText: 'Ingrese el nombre de usuario (opcional)',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 3) {
                      return 'El nombre de usuario debe tener al menos 3 caracteres';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                      return 'Solo se permiten letras, números y guión bajo';
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
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
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
              const SizedBox(height: 24),

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
                        'Nota: Los campos son opcionales. Si no se proporciona un nombre de usuario o contraseña, el usuario podrá ser creado y los roles pueden asignarse después.',
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
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: ThemeApp.primary),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: _isLoading ? 'Creando...' : 'Crear Usuario',
                      onPressed: _isLoading ? () {} : _crearUsuario,
                      isLoading: _isLoading,
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
}
