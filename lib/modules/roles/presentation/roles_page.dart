import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/roles/data/datasource/roles_remote_datasource.dart';
import 'package:resturant_funny/modules/roles/data/repository/roles_repository_impl.dart';
import 'package:resturant_funny/modules/roles/domain/roles_repository.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/not_found_card.dart';
import 'package:resturant_funny/shared/widgets/dialog_generic_widget.dart';

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
    final codCtrl = TextEditingController(text: rolExistente?.codigo ?? '');
    String estado = rolExistente?.estado ?? 'ACT';

    final esEdicion = rolExistente != null;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return DialogoPersonalizadoWidget(
              titulo: esEdicion ? 'Editar rol' : 'Nuevo rol',
              buttonTitle: esEdicion ? 'Guardar' : 'Crear',
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del rol',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Código del rol',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 11), // evita desborde
                      child: DropdownButtonFormField<String>(
                        value: estado,
                        isExpanded: true, // ocupa todo el ancho
                        decoration: const InputDecoration(
                          labelText: 'Nombre del rol',
                        ),
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
                        onChanged: (value) {
                          if (value == null) return;
                          setStateDialog(() {
                            estado = value; // actualiza y redibuja
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              onAceptarPressed: () async {
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
                      rolExistente,
                      nombre: nombre,
                      codigo: codCtrl.text.trim(),
                      estado: estado,
                    );
                  } else {
                    await _crearRol(
                      nombre: nombre,
                      codigo: codCtrl.text.trim(),
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
            );
          },
        );
      },
    );
  }

  Future<void> _crearRol({
    required String nombre,
    required String codigo,
    required String estado,
  }) async {
    final appState = ref.read(appStateProvider);

    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);

    try {
      final result = await _rolesRepository.createRol(
        nombre: nombre,
        codigo: codigo,
        estado: estado,
      );

      result.fold(
        (failure) {
          SnackHelper.show(
            context,
            message: failure.message,
            isSuccess: false,
          );
        },
        (nuevoRol) {
          if (!mounted) return;

          setState(() {
            _roles.insert(0, nuevoRol);
          });

          SnackHelper.show(
            context,
            message: 'Rol creado correctamente',
            isSuccess: true,
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      appState.setLoading(false);
    }
  }

  Future<void> _actualizarRol(
    RolEntity rol, {
    required String nombre,
    required String codigo,
    required String estado,
  }) async {
    final appState = ref.read(appStateProvider);

    setState(() => _isLoading = true);
    appState.setLoading(true);

    try {
      final result = await _rolesRepository.updateRol(
        rol,
        nombre: nombre,
        codigo: codigo,
        estado: estado,
      );

      result.fold(
        (failure) {
          SnackHelper.show(
            context,
            message: failure.message,
            isSuccess: false,
          );
        },
        (rolActualizado) {
          if (!mounted) return;

          setState(() {
            final index = _roles.indexWhere((r) => r.idRol == rol.idRol);
            if (index != -1) {
              _roles[index] = rolActualizado;
            }
          });

          SnackHelper.show(
            context,
            message: 'Rol actualizado correctamente',
            isSuccess: true,
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      appState.setLoading(false);
    }
  }

  Future<void> _eliminarRol(RolEntity rol) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => DialogoPersonalizadoWidget(
        titulo: 'Eliminar rol',
        buttonTitle: 'Eliminar',
        cancelTitle: 'Cancelar',
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            '¿Estás seguro de eliminar el rol "${rol.nombre}"? '
            'Esta acción no se puede deshacer.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        onAceptarPressed: () {
          Navigator.of(ctx).pop(true);
        },
        onCancelPressed: () {
          Navigator.of(ctx).pop(false);
        },
      ),
    );

    if (confirmar != true) return;

    final appState = ref.watch(appStateProvider);
    setState(() => _isLoading = true);
    appState.setLoading(true);
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
      appState.setLoading(false);
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
    return PantallaBase(
      title: widget.titulo,
      onBack: () => Navigator.of(context).pop(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ThemeApp.buildShimmerLoading();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_roles.isEmpty)
            const Expanded(
              child: Center(
                child: NotFoundCard(
                  message: 'No hay roles registrados',
                  icon: Icons.security_outlined,
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _cargarRoles,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, index) =>
                      _buildRolItem(ctx, _roles[index]),
                ),
              ),
            ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Crear rol',
            icon: Icons.add,
            onPressed: _crearRolDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildRolItem(BuildContext context, RolEntity rol) {
    final estadoColor = _colorEstado(rol.estado);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          rol.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rol.codigo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(rol.codigo),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _labelEstado(rol.estado),
                    style: TextStyle(
                      color: estadoColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ID: ${rol.idRol}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
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
  }
}
