import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/responsive_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/inventario/data/datasource/inventario_data_source.dart';
import 'package:resturant_funny/modules/inventario/data/repository/inventario_repository_impl.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/modules/inventario/domain/repository/inventario_repository.dart';
import 'package:resturant_funny/modules/inventario/presentation/inventario_detalle_page.dart';
import 'package:resturant_funny/modules/inventario/presentation/inventario_form_page.dart';
import 'package:resturant_funny/modules/inventario/presentation/widgets/inventario_admin_card.dart';
import 'package:resturant_funny/modules/inventario/presentation/widgets/inventario_pendiente_widget.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/main/presentation/widget/no_producto_widget.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class InventarioPage extends ConsumerStatefulWidget {
  const InventarioPage({super.key, required this.titulo});
  final String titulo;

  @override
  ConsumerState<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends ConsumerState<InventarioPage> {
  late final InventarioRepository _inventarioRepository;
  late final SucursalRepository _sucursalRepository;
  bool isEmployee = false;

  List<SucursalEntity> _sucursales = [];
  SucursalEntity? _selectedSucursal;
  List<InventarioEntity> _inventarios = [];
  List<InventarioEntity> _inventariosPendientes = [];

  @override
  void initState() {
    super.initState();
    _inventarioRepository = InventarioRepositoryImpl(
      InventarioRemoteDataSource(ref: ref),
    );
    _sucursalRepository =
        SucursalRemoteRepository(SucursalRemoteDataSource(ref: ref));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isEmployee = ref.read(isEmployeeProvider);
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    ref.read(appStateProvider.notifier).setLoading(true);

    final sucursalesResult = await _sucursalRepository.getSucursalesEntity();
    sucursalesResult.fold(
      (failure) {
        _handleError(failure.message);
        setState(() {
          _sucursales = [];
          ref.read(appStateProvider.notifier).setLoading(false);
        });
      },
      (sucursales) async {
        final activas = sucursales.where((s) => s.isActiva).toList();
        final selected = _resolveInitialSucursal(activas);

        setState(() {
          _sucursales = activas;
          _selectedSucursal = selected;
        });

        if (selected?.idSucursal != null) {
          await _fetchInventarios(selected!.idSucursal!);
        } else {
          ref.read(appStateProvider.notifier).setLoading(false);
        }
      },
    );
  }

  Future<void> _refreshInventarios() async {
    final selected = _selectedSucursal;
    if (selected?.idSucursal == null) return;
    await _fetchInventarios(selected!.idSucursal!);
  }

  Future<void> _fetchInventarios(int idSucursal) async {
    setState(() {
      ref.read(appStateProvider.notifier).setLoading(true);
    });

    final inventariosResult =
        await _inventarioRepository.getInventarioBySucursal(idSucursal);
    inventariosResult.fold(
      (failure) {
        _handleError(failure.message);
        setState(() {
          _inventarios = [];
          ref.read(appStateProvider.notifier).setLoading(false);
        });
      },
      (inventarios) {
        if (!mounted) return;
        setState(() {
          _inventarios = inventarios;
          ref.read(appStateProvider.notifier).setLoading(false);
        });
      },
    );
    final inventariosPendientesResult =
        await _inventarioRepository.getInventarioBySucursalPending(idSucursal);
    inventariosPendientesResult.fold(
      (failure) {
        _handleError(failure.message);
      },
      (inventariosPendientes) {
        setState(() {
          _inventariosPendientes = inventariosPendientes;
        });
      },
    );
  }

// Resuelve la sucursal inicial según el rol del usuario
  SucursalEntity? _resolveInitialSucursal(List<SucursalEntity> sucursales) {
    if (sucursales.isEmpty) return null;
    final user = ref.read(userProvider).user;
    if (user?.idSucursal != null) {
      try {
        return sucursales.firstWhere((s) => s.idSucursal == user!.idSucursal);
      } catch (_) {
        // Se usará la primera sucursal activa más abajo.
      }
    }
    return sucursales.isNotEmpty ? sucursales.first : null;
  }

  void _mostrarDetalleInventario(InventarioEntity inventario) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InventarioDetallePage(
          inventario: inventario,
          onEdit: () => _editarInventario(inventario),
          onDelete: () => _handleDelete(inventario),
        ),
      ),
    );
  }

  Future<void> _editarInventario(InventarioEntity inventario) async {
    if (_sucursales.isEmpty) {
      SnackHelper.show(context,
          message: 'No hay sucursales disponibles', isError: true);
      return;
    }

    final resultado = await InventarioFormPage.navigate(
      context: context,
      sucursales: _sucursales.where((s) => s.idSucursal != null).toList(),
      inventario: inventario,
      titulo: 'Editar inventario',
    );

    if (resultado == null || !mounted) return;

    final index = _inventarios
        .indexWhere((i) => i.idInventario == resultado.idInventario);
    if (index != -1) {
      setState(() {
        _inventarios[index] = resultado;
      });
    }

    if (mounted) {
      Navigator.of(context).pop();
      DialogHelper.success(context, message: 'Inventario actualizado',
          onConfirmed: () {
        // Navigator.of(context).pop();
        _refreshInventarios();
      });
    }
  }

  void _handleError(String message) {
    if (!mounted) return;
    SnackHelper.show(context, message: message, isError: true);
  }

  Future<void> _handleDelete(InventarioEntity inventario) async {
    try {
      DialogHelper.confirm(context,
          message:
              '¿Está seguro de eliminar el inventario ${inventario.nombre}?',
          onConfirm: () async {
        if (!mounted) return;
        ref.read(appStateProvider.notifier).setLoading(true);

        final result = await _inventarioRepository
            .deleteInventario(inventario.idInventario!);
        result.fold((failure) {
          ref.read(appStateProvider.notifier).setLoading(false);
          _handleError(failure.message);
        }, (ok) {
          setState(() {
            _inventarios
                .removeWhere((i) => i.idInventario == inventario.idInventario);
          });
          ref.read(appStateProvider.notifier).setLoading(false);
          DialogHelper.success(context, message: 'Inventario eliminado',
              onConfirmed: () {
            Navigator.of(context).pop();
            _refreshInventarios();
          });
          // Navigator.of(context).pop();
        });
      }, onCancel: () {});
    } catch (e) {
      _handleError(e.toString());
      debugPrint('Error al eliminar el inventario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(appStateProvider.select((state) => state.isLoading));

    return PantallaBase(
      onBack: () => Navigator.of(context).pop(),
      title: widget.titulo,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isEmployee) ...[
                    const Text('Seleccione la sucursal',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    CustomDropdown<SucursalEntity>(
                      value: _selectedSucursal,
                      label: 'Sucursal',
                      hint: 'Seleccione una sucursal',
                      displayText: (sucursal) => sucursal.nombre,
                      items: _sucursales,
                      onChanged: (sucursal) {
                        if (sucursal == null ||
                            sucursal.idSucursal ==
                                _selectedSucursal?.idSucursal) {
                          return;
                        }
                        setState(() {
                          _selectedSucursal = sucursal;
                        });
                        _fetchInventarios(sucursal.idSucursal!);
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text.rich(TextSpan(children: [
                    const TextSpan(text: 'Inventario de la sucursal: '),
                    TextSpan(
                        text: _selectedSucursal?.nombre ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(height: 8),
                  if (_inventariosPendientes.isNotEmpty)
                    InventarioPendienteWidget(
                      inventariosPendientes: _inventariosPendientes,
                      inventarioRepository: _inventarioRepository,
                      onRefresh: _refreshInventarios,
                      isLoading: isLoading,
                    ),
                  if (_inventariosPendientes.isNotEmpty)
                    const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _InventariosList(
                      isLoading: isLoading,
                      inventarios: _inventarios,
                      onRefresh: _refreshInventarios,
                      onSelect: _mostrarDetalleInventario,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
                icon: Icons.inventory_2,
                text: isEmployee
                    ? 'Solicitar Inventario'
                    : 'Registrar Inventario',
                onPressed: () async {
                  final result =
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => InventarioFormPage(
                                titulo: isEmployee
                                    ? 'Solicitar Inventario'
                                    : 'Registrar Inventario',
                                isEmployee: isEmployee,
                                sucursales: _sucursales,
                              )));
                  if (result != null) {
                    _fetchInventarios(_selectedSucursal?.idSucursal ?? 1);
                  }
                }),
          ),
        ],
      ),
    );
  }
}

class _InventariosList extends StatelessWidget {
  const _InventariosList({
    required this.isLoading,
    required this.inventarios,
    required this.onRefresh,
    required this.onSelect,
  });

  final bool isLoading;
  final List<InventarioEntity> inventarios;
  final Future<void> Function() onRefresh;
  final ValueChanged<InventarioEntity> onSelect;

  @override
  Widget build(BuildContext context) {
    if (isLoading && inventarios.isEmpty) {
      return ShimmerWidget.list(itemCount: 3);
    }

    return RefreshIndicator(
      color: ThemeApp.primary,
      onRefresh: onRefresh,
      child: inventarios.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                NoProductosWidget(message: 'No hay inventarios registrados')
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = ResponsiveUtil.columnsForGrid(
                  context,
                  minTileWidth: 200,
                  minColumns: 1,
                  maxColumns: 4,
                );

                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.1,
                  ),
                  itemCount: inventarios.length,
                  itemBuilder: (context, index) {
                    final inventario = inventarios[index];
                    return InventarioAdminCard(
                      inventario: inventario,
                      onTap: () => onSelect(inventario),
                    );
                  },
                );
              },
            ),
    );
  }
}
