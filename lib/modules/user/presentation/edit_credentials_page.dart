import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';

import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class EditCredentialsPage extends ConsumerStatefulWidget {
  final UserModel user;
  const EditCredentialsPage({super.key, required this.user});

  @override
  ConsumerState<EditCredentialsPage> createState() =>
      _EditCredentialsPageState();
}

class _EditCredentialsPageState extends ConsumerState<EditCredentialsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _saving = false;

  late final UsuariosRepositoryImpl _repo;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user.usuario ?? '');
    // Instancia el DataSource con ref y envuelvelo en el repo (maneja conectividad, etc.)
    final ds = UsuariosRemoteDataSource(ref: ref);
    _repo = UsuariosRepositoryImpl(ds);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.user.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontro el ID de usuario')),
      );
      return;
    }

    final int idUsuario = widget.user.idUsuario!;
    final String currentUsername = widget.user.usuario ?? '';
    final String newUsername = _usernameCtrl.text.trim();
    final String oldPass = _oldPassCtrl.text;
    final String newPass = _newPassCtrl.text;

    setState(() => _saving = true);
    try {
      if (newPass.trim().isEmpty || oldPass.trim().isEmpty) {
        DialogHelper.error(context,
            message: "Contraseñas requeridas", onConfirmed: () {});
        return;
      }
      //Actualizar nombre de usuario si cambio
      if (newUsername.isNotEmpty && newUsername != currentUsername) {
        final either = await _repo.updateUsuario(idUsuario, {
          'USUARIO': newUsername,
          // Para auditoria: 'USERMODIFICACION': currentUsername,
        });
        either.fold(
          (failure) => throw Exception(failure.message),
          (updated) {}, // no necesitamos el entity aqui
        );
      }

      //Cambiar contrasena si el campo nueva contrasena viene lleno
      if (newPass.isNotEmpty) {
        if (newPass.length < 6) {
          throw Exception('La contraseña debe tener mínimo 6 caracteres');
        }
        final either = await _repo.changePassword(
            idUsuario, oldPass, AppUtils.generateSha256(newPass));
        either.fold(
          (failure) => throw Exception(failure.message),
          (ok) {
            if (!ok) throw Exception('No se pudo cambiar la contraseña');
          },
        );
      }
      //Construir un UserModel actualizado para devolver a PerfilPage
      final updatedUser = UserModel(
        nombres: widget.user.nombres,
        apellidos: widget.user.apellidos,
        idUsuario: widget.user.idUsuario,
        usuario: newUsername.isNotEmpty ? newUsername : widget.user.usuario,
        password: (newPass.isNotEmpty ? newPass : widget.user.password),
        temporal: widget.user.temporal,
        fModificacionUsuario: DateTime.now(),
        userModificacion:
            newUsername.isNotEmpty ? newUsername : widget.user.userModificacion,
      );

      // Actualiza el singleton si lo usas como cache
      // SingletonApp.setUser(updatedUser);

      if (!mounted) return;
      DialogHelper.info(
        context,
        message: "Credenciales actualizadas correctamente",
        onConfirmed: () {
          Navigator.of(context).pop<UserModel>(updatedUser);
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.background,
      appBar: AppBar(
        title: const Text('Editar credenciales'),
        backgroundColor: ThemeApp.primary,
        foregroundColor: ThemeApp.baseText,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Usuario
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder().scale(2.5),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El usuario es requerido';
                    }
                    if (v.trim().length < 4) return 'Mínimo 4 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contrasena actual
                TextFormField(
                  controller: _oldPassCtrl,
                  obscureText: _obscureOld,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureOld
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscureOld = !_obscureOld),
                    ),
                    border: const OutlineInputBorder().scale(2.5),
                  ),
                ),
                const SizedBox(height: 16),

                // Nueva contrasena 
                TextFormField(
                  controller: _newPassCtrl,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureNew
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    border: const OutlineInputBorder().scale(2.5),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirmar
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureNew,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_reset),
                    border: const OutlineInputBorder().scale(2.5),
                  ),
                  validator: (v) {
                    if (_newPassCtrl.text.isNotEmpty &&
                        v != _newPassCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
