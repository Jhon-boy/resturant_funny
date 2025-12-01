// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/crear_mesa_dialog.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/crear_sucursal.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/mesa_mini_widget.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/sucursal_map_widget.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/data/datasource/rol_usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/persona_repository_impl.dart';
import 'package:resturant_funny/modules/user/data/repository/rol_usuario_impl.dart';
import 'package:resturant_funny/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/models/empleados_model.dart';
import 'package:resturant_funny/modules/user/domain/repository/persona_repository.dart';
import 'package:resturant_funny/modules/user/domain/repository/rol_usuario.dart';
import 'package:resturant_funny/modules/user/domain/repository/usuario_repository.dart';
import 'package:resturant_funny/modules/user/presentation/widget/empleado_card_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/enums/roles.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';

class SucursalDetallePage extends ConsumerStatefulWidget {
  final SucursalEntity sucursal;

  const SucursalDetallePage({
    super.key,
    required this.sucursal,
  });

  static Future<void> navigate({
    required BuildContext context,
    required SucursalEntity sucursal,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SucursalDetallePage(sucursal: sucursal),
      ),
    );
  }

  @override
  ConsumerState<SucursalDetallePage> createState() =>
      _SucursalDetallePageState();
}

class _SucursalDetallePageState extends ConsumerState<SucursalDetallePage> {
  late MesaRepository _mesaRepository;
  late UsuariosRepository _usuariosRepository;
  late PersonasRepository _personasRepository;
  late RolUsuarioRepository _rolUsuarioRepository;

  List<MesaEntity> _mesas = [];
  List<EmpleadoModel> _empleados = [];
  List<RolEntity> _roles = [];
  bool _isLoading = false;
  late SucursalEntity _sucursal;

  @override
  void initState() {
    super.initState();
    _sucursal = widget.sucursal;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mesaRepository = MesaRepositoryImpl(
        MesasRemoteDataSource(ref: ref),
      );
      _usuariosRepository = UsuariosRepositoryImpl(
        UsuariosRemoteDataSource(ref: ref),
      );
      _personasRepository = PersonaRepositoryImpl(
        PersonasRemoteDataSource(ref: ref),
      );
      _rolUsuarioRepository = RolUsuarioRepositoryImpl(
        RolUsuarioRemoteDataSource(ref: ref),
      );
      _cargarRoles();
      _cargarDatos();
    });
  }

  Future<void> _editarSucursal() async {
    final sucursalActualizada = await CrearSucursal.show(
      context: context,
      isEdit: true,
      sucursal: _sucursal,
    );

    if (sucursalActualizada != null && mounted) {
      setState(() {
        _sucursal = sucursalActualizada;
      });
      await _cargarDatos();
    }
  }

  Future<void> _eliminarMesa(MesaEntity mesa) async {
    final usuario = ref.read(userProvider).user;
    if (usuario == null) {
      SnackHelper.show(
        context,
        message: 'Error: No se pudo obtener la información del usuario',
        isError: true,
      );
      return;
    }

    DialogHelper.confirm(
      context,
      message: '¿Está seguro de eliminar la mesa ${mesa.numero}?',
      okText: 'Eliminar',
      onConfirm: () async {
        if (mesa.idMesa == null) return;

        final appState = ref.watch(appStateProvider);
        appState.setLoading(true);

        try {
          final result = await _mesaRepository.deleteMesa(
            mesa.idMesa.toString(),
            usuario,
          );

          result.fold(
            (failure) {
              appState.setLoading(false);
              if (mounted) {
                SnackHelper.show(
                  context,
                  message: 'Error al eliminar mesa: ${failure.message}',
                  isError: true,
                );
              }
            },
            (eliminado) {
              appState.setLoading(false);
              if (mounted) {
                setState(() {
                  _mesas.removeWhere((m) => m.idMesa == mesa.idMesa);
                });
                SnackHelper.show(
                  context,
                  message: 'Mesa eliminada correctamente',
                  isSuccess: true,
                );
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
      onCancel: () {},
    );
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

  Future<void> _cargarDatos() async {
    if (_sucursal.idSucursal == null) return;

    final appState = ref.watch(appStateProvider);
    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);

    try {
      final mesasResult =
          await _mesaRepository.getMesasBySucursal(_sucursal.idSucursal!);
      mesasResult.fold(
        (failure) {
          if (mounted) {
            SnackHelper.show(
              context,
              message: 'Error al cargar mesas: ${failure.message}',
              isError: true,
            );
          }
        },
        (mesas) {
          setState(() {
            _mesas = mesas;
          });
        },
      );

      final usuariosResult = await _usuariosRepository
          .getUsuariosBySucursal(_sucursal.idSucursal!);
      usuariosResult.fold(
        (failure) {
          if (mounted) {
            SnackHelper.show(
              context,
              message: 'Error al cargar empleados: ${failure.message}',
              isError: true,
            );
          }
        },
        (usuarios) async {
          final empleados = <EmpleadoModel>[];

          for (final usuario in usuarios) {
            // Obtener persona
            final personaResult = await _personasRepository
                .getPersonaByIdentificacion(usuario.identificacion);
            // Obtener roles
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
            _isLoading = false;
          });
          appState.setLoading(false);
        },
      );
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
    return PantallaBase(
      onBack: () => Navigator.of(context).pop(),
      title: _sucursal.nombre,
      body: contenido(),
    );
  }

  Widget contenido() {
    if (_isLoading && _mesas.isEmpty && _empleados.isEmpty) {
      return ThemeApp.buildShimmerLoading();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildSucursalInfo(),
          const SizedBox(height: 24),
          _buildMesasSection(),
          const SizedBox(height: 24),
          _buildEmpleadosSection(),
          const SizedBox(height: 24),
          SucursalMapWidget(
            latitud: _sucursal.latitud,
            longitud: _sucursal.longitud,
            sucursalNombre: _sucursal.nombre,
            sucursalContacto: _sucursal.contacto,
            enableSelection: false,
            height: 220,
          ),
        ],
      ),
    );
  }

  Widget _buildSucursalInfo() {
    return Card(
      elevation: 3,
      color: ThemeApp.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _sucursal.isActiva
                      ? ThemeApp.primary
                      : Colors.grey.shade400,
                  child: const Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sucursal.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
        children: [
          const Divider(),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Información General',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_sucursal.idSucursal != null)
                    _buildInfoRow(
                      icon: Icons.tag,
                      label: 'Sucursal',
                      value: _sucursal.idSucursal.toString(),
                    ),
                  // Dirección
                  if (_sucursal.direccion != null &&
                      _sucursal.direccion!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'Dirección',
                      value: _sucursal.direccion!,
                    ),
                  _buildInfoRow(
                    icon: _sucursal.isActiva
                        ? Icons.check_circle
                        : Icons.cancel_rounded,
                    label: 'Estado',
                    value: _sucursal.estado == true ? 'Activo' : 'Inactivo',
                  ),
                  if (_sucursal.fCreacion != null)
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Fecha de Creación',
                      value: AppUtils.formatDate(_sucursal.fCreacion),
                    ),

                  _buildInfoRow(
                    icon: Icons.edit_calendar,
                    label: 'Fecha de Modificación',
                    value: AppUtils.formatDate(_sucursal.fModificacion),
                  ),
                  _buildInfoRow(
                    icon: Icons.person_add,
                    label: 'Usuario de Ingreso',
                    value: _sucursal.usuarioIngreso ?? 'No disponible',
                  ),
                  _buildInfoRow(
                    icon: Icons.edit_document,
                    label: 'Usuario de Modificación',
                    value: _sucursal.userModificacion ?? 'No disponible',
                  ),
                  CustomButton(
                      icon: Icons.edit_document,
                      text: 'Editar Sucursal',
                      onPressed: _editarSucursal)
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: ThemeApp.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMesasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.table_restaurant,
                  size: 24,
                  color: ThemeApp.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mesas (${_mesas.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.primary,
                  ),
                ),
              ],
            ),
            TextButton(
                onPressed: () async {
                  if (_sucursal.idSucursal != null) {
                    final mesaCreada = await CrearMesaDialog.show(
                      context: context,
                      isEdit: false,
                      idSucursal: _sucursal.idSucursal!,
                    );
                    if (mesaCreada != null && mounted) {
                      setState(() {
                        _mesas.add(mesaCreada);
                      });
                    }
                  }
                },
                child: const Row(
                  children: [
                    Text(
                      'Agregar',
                      style: TextStyle(color: ThemeApp.success),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.add_business_outlined,
                      color: ThemeApp.success,
                      size: 30,
                    )
                  ],
                ))
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          SizedBox(
            height: 200,
            child: Center(
              child: ThemeApp.buildShimmerLoading(itemCount: 2),
            ),
          )
        else if (_mesas.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 24,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay mesas registradas en esta sucursal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._mesas.map((mesa) => MesaMiniWidget(
                mesa: mesa,
                onMesaUpdated: (mesaActualizada) {
                  setState(() {
                    final index = _mesas
                        .indexWhere((m) => m.idMesa == mesaActualizada.idMesa);
                    if (index != -1) {
                      _mesas[index] = mesaActualizada;
                    }
                  });
                },
                onMesaDeleted: (mesa) async {
                  await _eliminarMesa(mesa);
                },
              )),
      ],
    );
  }

  Widget _buildEmpleadosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.people,
              size: 24,
              color: ThemeApp.success,
            ),
            const SizedBox(width: 8),
            Text(
              'Empleados (${_empleados.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeApp.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          SizedBox(
            height: 200,
            child: Center(
              child: ThemeApp.buildShimmerLoading(itemCount: 2),
            ),
          )
        else if (_empleados.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 24,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay empleados registrados en esta sucursal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._empleados.map(
            (empleado) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: EmpleadoCardWidget(
                empleado: empleado,
                roles: _roles,
              ),
            ),
          ),
      ],
    );
  }
}
