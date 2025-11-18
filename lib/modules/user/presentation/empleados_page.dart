// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/data/datasource/rol_usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/persona_repository_impl.dart';
import 'package:resturant_funny/modules/user/data/repository/rol_usuario_impl.dart';
import 'package:resturant_funny/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/mappers/persona_mapper.dart';
import 'package:resturant_funny/modules/user/domain/mappers/usuario_mapper.dart';
import 'package:resturant_funny/modules/user/domain/models/empleados_model.dart';
import 'package:resturant_funny/modules/user/domain/repository/persona_repository.dart';
import 'package:resturant_funny/modules/user/domain/repository/rol_usuario.dart';
import 'package:resturant_funny/modules/user/domain/repository/usuario_repository.dart';
import 'package:resturant_funny/modules/user/presentation/crear_persona_page.dart';
import 'package:resturant_funny/modules/user/presentation/crear_usuario_page.dart';
import 'package:resturant_funny/modules/user/presentation/widget/dialogo_gestionar_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/dialogo_sucursales_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/empleado_card_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/modules/user/presentation/empleado_estadisticas_page.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/enums/roles.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/input_search_widget.dart';

class EmpleadosPage extends ConsumerStatefulWidget {
  final String titulo;
  const EmpleadosPage({super.key, required this.titulo});

  @override
  ConsumerState<EmpleadosPage> createState() => _EmpleadosPageState();
}

class _EmpleadosPageState extends ConsumerState<EmpleadosPage> {
  late RolUsuarioRepository _rolUsuarioRepository;
  late PersonasRepository _personasRepository;
  late UsuariosRepository _usuariosRepository;
  late SucursalRepository _sucursalRepository;
  List<EmpleadoModel> _empleados = [];
  List<EmpleadoModel> _empleadosFiltrados = [];
  List<RolEntity> _roles = [];
  List<SucursalEntity> _sucursales = [];
  final TextEditingController _searchController = TextEditingController();
  int _index = 0;
  bool _haRealizadoBusqueda = false;

  final List<String> _botones = [
    'Listar Empleados',
    'Adm. Empleado',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rolUsuarioRepository = RolUsuarioRepositoryImpl(
        RolUsuarioRemoteDataSource(ref: ref),
      );
      _personasRepository = PersonaRepositoryImpl(
        PersonasRemoteDataSource(ref: ref),
      );
      _usuariosRepository = UsuariosRepositoryImpl(
        UsuariosRemoteDataSource(ref: ref),
      );
      _sucursalRepository = SucursalRemoteRepository(
        SucursalRemoteDataSource(ref: ref),
      );
      //_cargarSucursales();
      _cargarRoles();
      _cargarSucursales();
      if (_index == 0) {
        _cargarEmpleados();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarRoles() async {
    try {
      final result = await _rolUsuarioRepository.getAllRoles();
      result.fold(
        (failure) {
          debugPrint('Error al cargar roles: ${failure.message}');
        },
        (roles) {
          setState(() {
            _roles = roles.where((rol) {
              final codigoCliente = Rol.CLIENTE.code;
              return rol.codigo.toUpperCase() != codigoCliente;
            }).toList();
          });
        },
      );
    } catch (e) {
      debugPrint('Error al cargar roles: $e');
    }
  }

  Future<void> _cargarSucursales() async {
    try {
      final result = await _sucursalRepository.getSucursalesEntity();
      result.fold((left) {
        debugPrint('Error al cargar las sucursales: ${left.message}');
      }, (sucursales) {
        setState(() {
          _sucursales = sucursales.where((s) => s.isActiva).toList();
        });
      });
    } catch (e) {
      debugPrint('Error al cargar las sucursales: $e');
    }
  }

  Future<void> _cargarEmpleados() async {
    final appState = ref.watch(appStateProvider);
    appState.setLoading(true);
    try {
      final usuariosResult =
          await _rolUsuarioRepository.getUsuariosSinRolCliente();

      final todosUsuarios = usuariosResult.fold(
        (failure) {
          appState.setLoading(false);
          if (mounted) {
            SnackHelper.show(
              context,
              message: 'Error al cargar empleados: ${failure.message}',
              isError: true,
            );
          }
          return <TUsuariEntity>[];
        },
        (usuarios) => usuarios,
      );

      if (todosUsuarios.isEmpty) {
        setState(() {
          _empleados = [];
          _empleadosFiltrados = [];
          appState.setLoading(false);
        });
        return;
      }

      final usuariosUnicos = <int, TUsuariEntity>{};
      for (final usuario in todosUsuarios) {
        usuariosUnicos[usuario.idUsuario] = usuario;
      }

      final empleados = <EmpleadoModel>[];
      for (final usuario in usuariosUnicos.values) {
        final personaResult = await _personasRepository
            .getPersonaByIdentificacion(usuario.identificacion);
        final rolesResult =
            await _rolUsuarioRepository.getRolesUsuario(usuario.idUsuario);

        personaResult.fold(
          (l) => null,
          (persona) {
            rolesResult.fold(
              (l) => null,
              (roles) {
                empleados.add(EmpleadoModel(
                  usuario: usuario,
                  persona: persona,
                  roles: roles,
                ));
              },
            );
          },
        );
      }

      setState(() {
        _empleados = empleados;
        _empleadosFiltrados = empleados;
        appState.setLoading(false);
      });
    } catch (e) {
      appState.setLoading(false);
      if (mounted) {
        SnackHelper.show(
          context,
          message: 'Error al cargar empleados: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _crearNuevaPersona() async {
    final identificacion = _searchController.text.trim();
    if (identificacion.isEmpty) {
      SnackHelper.show(
        context,
        message: 'Por favor ingrese una identificación',
        isError: true,
      );
      return;
    }

    final personaCreada = await CrearPersonaPage.navigate(
      context: context,
      titulo: "Registrar Nueva Persona",
      identificacion: identificacion,
    );

    if (personaCreada != null && mounted) {
      await _buscarPersona(identificacion);

      SnackHelper.show(
        context,
        message: "Persona registrada exitosamente",
        isSuccess: true,
      );
    }
  }

  Future<void> _buscarPersona(String identificacion) async {
    final appState = ref.watch(appStateProvider);
    try {
      if (identificacion.isEmpty) {
        setState(() {
          _empleadosFiltrados = _empleados;
          _haRealizadoBusqueda = false;
        });
        return;
      }
      setState(() {
        _haRealizadoBusqueda = true;
      });
      appState.setLoading(true);

      final personaResult =
          await _personasRepository.getPersonaByIdentificacion(identificacion);

      personaResult.fold(
        (failure) {
          setState(() {
            _empleadosFiltrados = [];
          });
          appState.setLoading(false);
          // No mostrar error, solo dejar que se muestre el botón de crear
          debugPrint('Error al buscar empleado: ${failure.message}');
        },
        (persona) async {
          final usuarioResult = await _usuariosRepository
              .getUsuarioByIdentificacion(persona.identificacion);

          usuarioResult.fold(
            (failure) {
              setState(() {
                _empleadosFiltrados = [
                  EmpleadoModel(
                    usuario: null,
                    persona: persona,
                    roles: [],
                  )
                ];
              });
            },
            (usuario) async {
              final rolesResult = await _rolUsuarioRepository
                  .getRolesUsuario(usuario.idUsuario);

              rolesResult.fold(
                (l) {
                  setState(() {
                    _empleadosFiltrados = [
                      EmpleadoModel(
                        usuario: usuario,
                        persona: persona,
                        roles: [],
                      )
                    ];
                  });
                },
                (roles) {
                  setState(() {
                    _empleadosFiltrados = [
                      EmpleadoModel(
                        usuario: usuario,
                        persona: persona,
                        roles: roles,
                      )
                    ];
                  });
                },
              );
            },
          );
        },
      );
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> _actualizarEmpleadoConUsuario(
      EmpleadoModel empleado, TUsuariEntity usuarioCreado) async {
    final appState = ref.watch(appStateProvider);
    appState.setLoading(true);

    try {
      final rolesResult =
          await _rolUsuarioRepository.getRolesUsuario(usuarioCreado.idUsuario);

      rolesResult.fold(
        (failure) {
          _actualizarEmpleadoEnLista(
            empleado,
            EmpleadoModel(
              usuario: usuarioCreado,
              persona: empleado.persona,
              roles: [],
            ),
          );
        },
        (roles) {
          final empleadoActualizado = EmpleadoModel(
            usuario: usuarioCreado,
            persona: empleado.persona,
            roles: roles,
          );
          _actualizarEmpleadoEnLista(empleado, empleadoActualizado);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _gestionarRoles(empleadoActualizado);
            }
          });
        },
      );
    } catch (e) {
      SnackHelper.show(
        context,
        message: 'Error al actualizar empleado: $e',
        isError: true,
      );
    } finally {
      appState.setLoading(false);
    }
  }

  /// Actualiza un empleado específico en las listas sin recargar todo
  void _actualizarEmpleadoEnLista(
      EmpleadoModel empleadoViejo, EmpleadoModel empleadoNuevo) {
    setState(() {
      // Actualizar en _empleados
      final indexEmpleados = _empleados.indexWhere(
        (e) => e.persona.identificacion == empleadoViejo.persona.identificacion,
      );
      if (indexEmpleados != -1) {
        _empleados[indexEmpleados] = empleadoNuevo;
      }

      // Actualizar en _empleadosFiltrados
      final indexFiltrados = _empleadosFiltrados.indexWhere(
        (e) => e.persona.identificacion == empleadoViejo.persona.identificacion,
      );
      if (indexFiltrados != -1) {
        _empleadosFiltrados[indexFiltrados] = empleadoNuevo;
      }
    });
  }

  Future<void> _gestionarSucursal(EmpleadoModel empleado) async {
    if (empleado.usuario == null) {
      DialogHelper.info(
        context,
        message:
            'Esta persona no tiene usuario. Por favor, cree un usuario primero antes de cambiar la sucursal.',
        dismissible: true,
        onConfirmed: () {},
      );
      return;
    }

    if (_sucursales.isEmpty) {
      SnackHelper.show(
        context,
        message: 'Cargando sucursales, por favor espere...',
        isError: true,
      );
      await _cargarSucursales();
      if (_sucursales.isEmpty) {
        SnackHelper.show(
          context,
          message: 'No se pudieron cargar las sucursales',
          isError: true,
        );
        return;
      }
    }

    await showDialog(
      context: context,
      builder: (context) => GestionarSucursalesDialog(
        idSucursalActual: empleado.usuario?.idSucursal,
        sucursales: _sucursales,
        nombrePersona:
            '${empleado.persona.nombres} ${empleado.persona.apellidos}',
        onSucursalSeleccionada: (sucursal) async {
          if (empleado.usuario == null) return;

          final appState = ref.watch(appStateProvider);
          appState.setLoading(true);

          try {
            final result = await _usuariosRepository.updateUsuario(
              empleado.usuario!.idUsuario,
              UsuarioMapper.updateSucursalUsuario(sucursal),
            );

            result.fold(
              (failure) {
                appState.setLoading(false);
                if (mounted) {
                  SnackHelper.show(
                    context,
                    message: 'Error al cambiar sucursal: ${failure.message}',
                    isError: true,
                  );
                }
              },
              (usuarioActualizado) {
                appState.setLoading(false);
                if (mounted) {
                  DialogHelper.success(context,
                      message: 'Sucursal actualizada correctamente',
                      onConfirmed: () {});
                  // Actualizar el empleado en la lista
                  final empleadoActualizado = EmpleadoModel(
                    usuario: usuarioActualizado,
                    persona: empleado.persona,
                    roles: empleado.roles,
                  );
                  _actualizarEmpleadoEnLista(empleado, empleadoActualizado);
                }
              },
            );
          } catch (e) {
            appState.setLoading(false);
            if (mounted) {
              SnackHelper.show(
                context,
                message: 'Error inesperado: $e',
                isError: true,
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _gestionarRoles(EmpleadoModel empleado) async {
    // Si no tiene usuario, mostrar mensaje para crear usuario primero
    if (empleado.usuario == null) {
      DialogHelper.info(
        context,
        message:
            'Esta persona no tiene usuario. Por favor, cree un usuario primero desde la sección "Crear Persona" antes de asignar roles.',
        dismissible: true,
        onConfirmed: () {},
      );
      return;
    }

    if (_roles.isEmpty) {
      SnackHelper.show(
        context,
        message: 'Cargando roles, por favor espere...',
        isError: true,
      );
      await _cargarRoles();
      if (_roles.isEmpty) {
        SnackHelper.show(
          context,
          message: 'No se pudieron cargar los roles',
          isError: true,
        );
        return;
      }
    }

    final rolesActuales = empleado.roles;

    await showDialog(
      context: context,
      builder: (context) => GestionarRolesDialog(
        empleado: empleado,
        rolesActuales: rolesActuales,
        rolesDisponibles: _roles,
        onAgregarRol: (rol) async {
          if (empleado.usuario == null) return;
          final result = await _rolUsuarioRepository.agregarRolUsuarioById(
            empleado.usuario!.idUsuario,
            rol.idRol,
          );
          result.fold(
            (l) {
              SnackHelper.show(
                context,
                message: 'Error al agregar rol: ${l.message}',
                isError: true,
              );
            },
            (r) {
              SnackHelper.show(
                context,
                message: 'Rol agregado correctamente',
                isSuccess: true,
              );
              _cargarEmpleados();
            },
          );
        },
        onQuitarRol: (rol) async {
          if (empleado.usuario == null) return;
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 150));

          if (!mounted) return;

          DialogHelper.confirm(
            context,
            message:
                "¿Está seguro de quitar el rol '${rol.nombre}' a ${empleado.persona.nombres}?",
            onConfirm: () async {
              if (!mounted || empleado.usuario == null) return;
              final result = await _rolUsuarioRepository.quitarRolUsuarioById(
                empleado.usuario!.idUsuario,
                rol.idRol,
              );
              result.fold(
                (l) {
                  if (!mounted) return;
                  SnackHelper.show(
                    context,
                    message: 'Error al quitar rol: ${l.message}',
                    isError: true,
                  );
                },
                (r) {
                  if (!mounted) return;
                  SnackHelper.show(
                    context,
                    message: 'Rol quitado correctamente',
                    isSuccess: true,
                  );
                  _cargarEmpleados();
                },
              );
            },
            onCancel: () {
              debugPrint('Cancelado');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _gestionarRoles(empleado);
                }
              });
            },
          );
        },
      ),
    );
  }

  Future<void> _eliminarEmpleado(EmpleadoModel empleado) async {
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
      final result = await _personasRepository.updatePersona(
        empleado.persona.identificacion,
        PersonaMapper.deletePersona(user),
      );

      result.fold(
        (failure) {
          appState.setLoading(false);
          SnackHelper.show(context,
              message: 'Error al eliminar: ${failure.message}', isError: true);
        },
        (personaActualizada) {
          appState.setLoading(false);
          setState(() {
            _empleados.removeWhere((e) =>
                e.persona.identificacion == personaActualizada.identificacion);
            _empleadosFiltrados.removeWhere((e) =>
                e.persona.identificacion == personaActualizada.identificacion);
          });
          DialogHelper.success(context,
              message: 'Empleado desactivado exitosamente',
              dismissible: true, onConfirmed: () {
            if (_index == 0) {
              _cargarEmpleados();
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
    final appState = ref.watch(appStateProvider);
    return PantallaBase(
      title: widget.titulo,
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tabs con ChoiceChip
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
                        onSelected: (_) {
                          setState(() {
                            _index = i;
                            if (i == 0) {
                              _cargarEmpleados();
                            } else {
                              _empleadosFiltrados = [];
                              _haRealizadoBusqueda = false;
                              _searchController.clear();
                            }
                          });
                        },
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
            const SizedBox(height: 10),

            if (_index == 0) ...[
              if (appState.isLoading)
                ShimmerWidget.list()
              else if (_empleadosFiltrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No hay empleados registrados',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else ...[
                _buildSectionTitle(
                    'Empleados Encontrados (${_empleadosFiltrados.length})'),
                const Divider(),
                const SizedBox(height: 8),
                ..._empleadosFiltrados.map((empleado) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: EmpleadoCardWidget(
                      empleado: empleado,
                      roles: _roles,
                      onEdit: () async {
                        if (empleado.usuario == null) {
                          // Si no tiene usuario, crear uno
                          final usuarioCreado = await CrearUsuarioPage.navigate(
                            context: context,
                            identificacion: empleado.persona.identificacion,
                            persona: empleado.persona,
                            titulo: 'Crear Usuario',
                            sucursales: _sucursales,
                          );
                          if (usuarioCreado != null && mounted) {
                            setState(() {
                              _index = 0;
                              _cargarEmpleados();
                            });
                          }
                        } else {
                          _gestionarRoles(empleado);
                        }
                      },
                      onChangeSucursal: () {
                        _gestionarSucursal(empleado);
                      },
                      onViewStatistics: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EmpleadoEstadisticasPage(
                              empleado: empleado,
                            ),
                          ),
                        );
                      },
                      onDelete: () async {
                        DialogHelper.confirm(context,
                            okText: 'Desactivar',
                            message:
                                '¿Está seguro de desactivar este empleado?. Al confirmar esta acción el empleado ya no podrá acceder a la aplicación.',
                            onConfirm: () {
                          _eliminarEmpleado(empleado);
                        }, onCancel: () {
                          debugPrint('Cancelado');
                        });
                      },
                    ),
                  );
                })
              ],
            ],

            if (_index == 1) ...[
              // Tab Buscar
              InputSearchWidget(
                label: 'Identificación',
                hint: 'Ej: 0102030405',
                showSuffixButton: false,
                onSubmitted: (value) async {
                  _searchController.text = value;
                  _buscarPersona(_searchController.text);
                },
                onChanged: (value) {
                  setState(() {
                    _searchController.text = value;
                  });
                },
              ),
              const SizedBox(height: 8),

              if (appState.isLoading)
                ShimmerWidget.list()
              else if (_empleadosFiltrados.isNotEmpty)
                ..._empleadosFiltrados.map((empleado) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: EmpleadoCardWidget(
                      empleado: empleado,
                      roles: _roles,
                      onEdit: () async {
                        if (empleado.usuario == null) {
                          final usuarioCreado = await CrearUsuarioPage.navigate(
                            context: context,
                            identificacion: empleado.persona.identificacion,
                            persona: empleado.persona,
                            titulo: 'Crear Usuario',
                            sucursales: _sucursales,
                          );
                          if (usuarioCreado != null && mounted) {
                            await _actualizarEmpleadoConUsuario(
                                empleado, usuarioCreado);
                          }
                        } else {
                          _gestionarRoles(empleado);
                        }
                      },
                      onDelete: () async {
                        DialogHelper.confirm(context,
                            message:
                                '¿Está seguro de desactivar este empleado?',
                            onConfirm: () {
                          _eliminarEmpleado(empleado);
                        }, onCancel: () {
                          debugPrint('Cancelado');
                        });
                      },
                      onChangeSucursal: () {
                        _gestionarSucursal(empleado);
                      },
                      onViewStatistics: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EmpleadoEstadisticasPage(
                              empleado: empleado,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                })
              else if (_empleadosFiltrados.isEmpty && _haRealizadoBusqueda) ...[
                // Mostrar opción para crear persona
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_add_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No se encontró una persona con la identificación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchController.text.trim(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ThemeApp.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Crear Nueva Persona',
                        colorButton: ThemeApp.primary,
                        colorText: Colors.white,
                        icon: Icons.person_add,
                        onPressed: () {
                          _crearNuevaPersona();
                        },
                      ),
                    ],
                  ),
                ),
              ] else if (_empleadosFiltrados.isEmpty &&
                  !_haRealizadoBusqueda) ...[
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Ingrese una identificación para buscar',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ],
          ],
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
