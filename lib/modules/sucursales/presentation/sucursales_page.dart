// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/data/repository/mesa_repository_impl.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/crear_sucursal.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/sucursal_card_widget.dart';
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
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';

class SucursalesPage extends ConsumerStatefulWidget {
  const SucursalesPage({super.key, required this.titulo});
  final String titulo;

  @override
  ConsumerState<SucursalesPage> createState() => _SucursalesPageState();
}

class _SucursalesPageState extends ConsumerState<SucursalesPage> {
  late SucursalRepository _sucursalRepository;
  late MesaRepository _mesaRepository;
  late UsuariosRepository _usuariosRepository;
  late PersonasRepository _personasRepository;
  late RolUsuarioRepository _rolUsuarioRepository;

  List<SucursalEntity> _sucursales = [];
  final Map<int, List<MesaEntity>> _mesasPorSucursal = {};
  final Map<int, List<EmpleadoModel>> _empleadosPorSucursal = {};
  final Map<int, bool> _loadingPorSucursal = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sucursalRepository = SucursalRemoteRepository(
        SucursalRemoteDataSource(ref: ref),
      );
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
      _cargarSucursales();
    });
  }

  Future<void> _cargarSucursales() async {
    final appState = ref.watch(appStateProvider);
    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);

    try {
      final result = await _sucursalRepository.getSucursalesEntity();
      result.fold(
        (failure) {
          appState.setLoading(false);
          if (mounted) {
            SnackHelper.show(
              context,
              message: 'Error al cargar sucursales: ${failure.message}',
              isError: true,
            );
          }
        },
        (sucursales) async {
          setState(() {
            _sucursales = sucursales;
            _isLoading = false;
          });
          appState.setLoading(false);

          for (final sucursal in sucursales) {
            if (sucursal.idSucursal != null) {
              await _cargarDatosSucursal(sucursal.idSucursal!);
            }
          }
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

  Future<void> _cargarDatosSucursal(int idSucursal) async {
    setState(() {
      _loadingPorSucursal[idSucursal] = true;
    });

    try {
      // Cargar mesas
      final mesasResult = await _mesaRepository.getMesasBySucursal(idSucursal);
      mesasResult.fold(
        (failure) {
          debugPrint('Error al cargar mesas: ${failure.message}');
        },
        (mesas) {
          setState(() {
            _mesasPorSucursal[idSucursal] = mesas;
          });
        },
      );

      // Cargar empleados
      final usuariosResult =
          await _usuariosRepository.getUsuariosBySucursal(idSucursal);
      usuariosResult.fold(
        (failure) {
          debugPrint('Error al cargar usuarios: ${failure.message}');
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
            _empleadosPorSucursal[idSucursal] = empleados;
            _loadingPorSucursal[idSucursal] = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _loadingPorSucursal[idSucursal] = false;
      });
      debugPrint('Error al cargar datos de sucursal: $e');
    }
  }

  Future<void> _eliminarSucursal(SucursalEntity sucursal) async {
    if (sucursal.idSucursal == null) return;

    final appState = ref.read(appStateProvider);
    appState.setLoading(true);
    final usuario = SingletonApp.getUser();

    final result = await _sucursalRepository.deleteSucursalEntity(
      sucursal.idSucursal!,
      usuario!.idUsuario!.toString(),
    );

    result.fold(
      (failure) {
        appState.setLoading(false);
        if (!mounted) return;

        SnackHelper.show(
          context,
          message: 'Error al eliminar sucursal: ${failure.message}',
          isError: true,
        );
        _cargarSucursales();
      },
      (success) {
        appState.setLoading(false);
        if (!mounted) return;

        SnackHelper.show(
          context,
          message: 'Sucursal eliminada correctamente',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      onBack: () => Navigator.of(context).pop(),
      title: widget.titulo,
      body: contenido(),
    );
  }

  Widget contenido() {
    if (_isLoading) {
      return ThemeApp.buildShimmerLoading();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_sucursales.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay sucursales registradas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _sucursales.length,
                itemBuilder: (context, index) {
                  final sucursal = _sucursales[index];
                  final idSucursal = sucursal.idSucursal;
                  final mesas = idSucursal != null
                      ? (_mesasPorSucursal[idSucursal] ?? [])
                      : <MesaEntity>[];
                  final empleados = idSucursal != null
                      ? (_empleadosPorSucursal[idSucursal] ?? [])
                      : <EmpleadoModel>[];

                  return Dismissible(
                    key: ValueKey('sucursal_${sucursal.idSucursal}_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(),
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Eliminar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar sucursal'),
                              content: Text(
                                  '¿Deseas eliminar la sucursal "${sucursal.nombre}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                    },
                    onDismissed: (direction) {
                      setState(() {
                        _sucursales.removeAt(index);
                        if (idSucursal != null) {
                          _mesasPorSucursal.remove(idSucursal);
                          _empleadosPorSucursal.remove(idSucursal);
                          _loadingPorSucursal.remove(idSucursal);
                        }
                      });
                      _eliminarSucursal(sucursal);
                    },
                    child: SucursalCardWidget(
                      sucursal: sucursal,
                      mesas: mesas,
                      empleados: empleados,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          CustomButton(
            icon: Icons.add_business_rounded,
            text: 'Crear Sucursal',
            onPressed: () async {
              final result = await CrearSucursal.show(
                context: context,
                isEdit: false,
              );
              if (result != null && mounted) {
                _cargarSucursales();
              }
            },
          ),
        ],
      ),
    );
  }
}
