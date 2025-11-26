import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/roles/data/datasource/roles_remote_datasource.dart';
import 'package:resturant_funny/modules/roles/data/repository/roles_repository_impl.dart';
import 'package:resturant_funny/modules/roles/domain/roles_repository.dart';

class RolesPage extends ConsumerStatefulWidget {
  const RolesPage({super.key, required this.titulo});
  final String titulo;

  @override
  ConsumerState<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends ConsumerState<RolesPage> {
  bool _isLoading = false;
  List<RolEntity> _roles = [];
  late RolesRepository _rolesRepository;

  @override
  void initState() {
    super.initState();
    _rolesRepository = RolesRepositoryImpl(
      RolesRemoteDataSource(ref: ref),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarRoles();
    });
  }

  Future<void> _cargarRoles() async {
    final appState = ref.watch(appStateProvider);
    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);
    try {
      final result = await _rolesRepository.cargarRoles();
      result.fold((failure) {
        if (mounted) {
          SnackHelper.show(
            context,
            message: 'Error al cargar roles: ${failure.message}',
            isError: true,
          );
        }
      }, (roles) {
        if (!mounted) return;
        setState(() {
          _roles = roles;
        });
      });
    } catch (e) {
      if (mounted) {
        SnackHelper.show(
          context,
          message: 'Error inesperado: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      appState.setLoading(false);
    }
  }

  Future<void> _crearRolDialog() async {
    await _mostrarDialogoRol();
  }

  Future<void> _editarRolDialog(RolEntity rol) async {
    await _mostrarDialogoRol(rolExistente: rol);
  }

  Future<void> _mostrarDialogoRol({RolEntity? rolExistente}) async {
    final nombreCtrl = TextEditingController(text: rolExistente?.nombre ?? '');
    final obsCtrl =
        TextEditingController(text: rolExistente?.observacion ?? '');
    String estado = rolExistente?.estado ?? 'ACT';

    final esEdicion = rolExistente != null;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(esEdicion ? 'Editar rol' : 'Nuevo rol'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: obsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Observación',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: estado,
                  items: const [
                    DropdownMenuItem(
                      value: 'ACT',
                      child: Text('Activo'),
                    ),
                    DropdownMenuItem(
                      value: 'INA',
                      child: Text('Inactivo'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      estado = val;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = nombreCtrl.text.trim();

                if (nombre.isEmpty) {
                  SnackHelper.show(
                    context,
                    message: 'El nombre del rol es obligatorio',
                    isError: true,
                  );
                  return;
                }

                try {
                  if (esEdicion) {
                    await _actualizarRol(
                      rolExistente!,
                      nombre: nombre,
                      observacion: obsCtrl.text.trim(),
                      estado: estado,
                    );
                  } else {
                    await _crearRol(
                      nombre: nombre,
                      observacion: obsCtrl.text.trim(),
                      estado: estado,
                    );
                  }
                  if (mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  SnackHelper.show(
                    context,
                    message: 'Error guardando rol: $e',
                    isError: true,
                  );
                }
              },
              child: Text(esEdicion ? 'Guardar' : 'Crear'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _crearRol({
    required String nombre,
    required String observacion,
    required String estado,
  }) async {
    final appState = ref.watch(appStateProvider);
    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);
    try {
      final result = await _rolesRepository.createRol(
          nombre: nombre, observacion: observacion, estado: estado);
      final nuevoRol = RolEntity.fromJson(result as Map<String, dynamic>);

      setState(() {
        _roles.insert(0, nuevoRol);
      });

      SnackHelper.show(
        context,
        message: 'Rol creado correctamente',
        isSuccess: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _actualizarRol(
    RolEntity rol, {
    required String nombre,
    required String observacion,
    required String estado,
  }) async {
    setState(() => _isLoading = true);
    try {
      final result = await _rolesRepository.updateRol(rol,
          nombre: nombre, observacion: observacion, estado: estado);
      final actualizado = RolEntity.fromJson(result as Map<String, dynamic>);

      setState(() {
        final index = _roles.indexWhere((r) => r.idRol == rol.idRol);
        if (index != -1) {
          _roles[index] = actualizado;
        }
      });

      SnackHelper.show(
        context,
        message: 'Rol actualizado correctamente',
        isSuccess: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _eliminarRol(RolEntity rol) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar rol'),
        content: Text(
          '¿Estás seguro de eliminar el rol "${rol.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);
    try {
      await _rolesRepository.deleteRol(rol);
      setState(() {
        _roles.removeWhere((r) => r.idRol == rol.idRol);
      });

      SnackHelper.show(
        context,
        message: 'Rol eliminado correctamente',
        isSuccess: true,
      );
    } catch (e) {
      SnackHelper.show(
        context,
        message: 'Error eliminando rol: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'ACT':
        return ThemeApp.success;
      case 'INA':
        return ThemeApp.error;
      default:
        return Colors.grey;
    }
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case 'ACT':
        return 'ACTIVO';
      case 'INA':
        return 'INACTIVO';
      default:
        return estado.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearRolDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _roles.isEmpty
              ? const Center(child: Text('No hay roles registrados'))
              : RefreshIndicator(
                  onRefresh: _cargarRoles,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _roles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final rol = _roles[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            rol.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (rol.observacion != null &&
                                  rol.observacion!.isNotEmpty)
                                Text(rol.observacion!),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _colorEstado(rol.estado)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _labelEstado(rol.estado),
                                      style: TextStyle(
                                        color: _colorEstado(rol.estado),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ID: ${rol.idRol}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editarRolDialog(rol),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _eliminarRol(rol),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
