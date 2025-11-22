import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:resturant_funny/modules/user/data/repository/persona_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/repository/usuario_repository.dart';
import 'package:resturant_funny/modules/user/domain/repository/persona_repository.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/reporte_data_table_widget.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/not_found_card.dart';

class ReporteTotalUsuariosPage extends ConsumerStatefulWidget {
  const ReporteTotalUsuariosPage({super.key, required this.sucursales});
  final List<SucursalEntity> sucursales;

  @override
  ConsumerState<ReporteTotalUsuariosPage> createState() =>
      _ReporteTotalUsuariosPageState();
}

class _ReporteTotalUsuariosPageState
    extends ConsumerState<ReporteTotalUsuariosPage> {
  late UsuariosRepository _usuariosRepository;
  late PersonasRepository _personasRepository;

  // Filtros
  SucursalEntity? _sucursalSeleccionada;
  DateTime? _fechaInicio;
  DateTime? _fechaHasta;

  List<TUsuariEntity> _usuarios = [];
  final Map<String, PersonaEntity> _personasMap = {};
  int _totalUsuarios = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usuariosRepository = UsuariosRepositoryImpl(
        UsuariosRemoteDataSource(ref: ref),
      );
      _personasRepository = PersonaRepositoryImpl(
        PersonasRemoteDataSource(ref: ref),
      );
    });
  }

  Future<void> _cargarDatos() async {
    ref.read(appStateProvider.notifier).setLoading(true);
    if (_sucursalSeleccionada == null) {
      DialogHelper.error(context, message: 'Por favor seleccione una sucursal',
          onConfirmed: () {
        Navigator.of(context).pop();
      });
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    if (_fechaInicio == null || _fechaHasta == null) {
      DialogHelper.error(context,
          message: 'Por favor seleccione el rango de fechas',
          onConfirmed: () {});
      ref.read(appStateProvider.notifier).setLoading(false);
      return;
    }

    setState(() {
      _usuarios = [];
      _personasMap.clear();
    });

    try {
      // Obtener usuarios por sucursal y fechas
      final usuariosResult = await _usuariosRepository.getUsuariosBySucursal(
        _sucursalSeleccionada!.idSucursal!,
        fechaDesde: _fechaInicio,
        fechaHasta: _fechaHasta,
      );

      usuariosResult.fold(
        (failure) {
          DialogHelper.error(context, message: failure.message,
              onConfirmed: () {
            Navigator.of(context).pop();
          });
          if (mounted) {
            SnackHelper.show(context, message: failure.message, isError: true);
          }
        },
        (usuarios) async {
          _usuarios = usuarios;
          _totalUsuarios = usuarios.length;

          for (final usuario in usuarios) {
            final personaResult = await _personasRepository
                .getPersonaByIdentificacion(usuario.identificacion);
            personaResult.fold(
              (failure) {
                debugPrint(
                    'No se encontró persona para ${usuario.identificacion}');
              },
              (persona) {
                _personasMap[usuario.identificacion] = persona;
              },
            );
          }

          if (mounted) {
            setState(() {});
          }
        },
      );
    } catch (e) {
      DialogHelper.error(context, message: 'Error inesperado: $e',
          onConfirmed: () {
        Navigator.of(context).pop();
      });
      if (mounted) {
        SnackHelper.show(context,
            message: 'Error inesperado: $e', isError: true);
      }
    } finally {
      ref.read(appStateProvider.notifier).setLoading(false);
    }
  }

  Future<void> _generarPDF() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando PDF...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: 'Total de Usuarios',
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros
            _buildFiltros(),
            const SizedBox(height: 24),
            // Contenido del reporte
            _buildContenidoReporte(),
            const SizedBox(height: 24),
            // Botón para generar PDF
            CustomButton(
              text: 'Generar PDF',
              colorButton: ThemeApp.primary,
              colorText: Colors.white,
              icon: Icons.picture_as_pdf,
              onPressed: _generarPDF,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoReporte() {
    return ref.watch(appStateProvider).isLoading
        ? Center(child: ShimmerWidget.list(itemCount: 3))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstadisticas(),
              const SizedBox(height: 24),
              _buildListaUsuarios(),
            ],
          );
  }

  Widget _buildEstadisticas() {
    // Calcular usuarios por día
    final usuariosPorDia = <String, int>{};
    for (final usuario in _usuarios) {
      if (usuario.fCreacion != null) {
        final fecha = AppUtils.formatDate(usuario.fCreacion);
        usuariosPorDia[fecha] = (usuariosPorDia[fecha] ?? 0) + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeApp.baseText,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people, color: ThemeApp.primary, size: 28),
              SizedBox(width: 12),
              Text(
                'Estadísticas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Total de usuarios
          _buildStatCard(
            'Total de Usuarios',
            _totalUsuarios.toString(),
            Icons.people_outline,
            Colors.blue,
          ),
          const SizedBox(height: 16),
          // Usuarios por día
          if (usuariosPorDia.isNotEmpty) ...[
            const Text(
              'Usuarios por Día',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeApp.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...usuariosPorDia.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeApp.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ThemeApp.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${entry.value} usuario${entry.value > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemeApp.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String titulo, String valor, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ThemeApp.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeApp.baseText,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeApp.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.store, color: ThemeApp.primary),
              SizedBox(width: 8),
              Text('Sucursal',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          CustomDropdown<SucursalEntity>(
            value: _sucursalSeleccionada,
            label: 'Sucursal',
            hint: 'Seleccione una sucursal',
            items: widget.sucursales,
            displayText: (s) => s.nombre,
            onChanged: (s) {
              setState(() => _sucursalSeleccionada = s);
            },
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.calendar_today, color: ThemeApp.primary),
              SizedBox(width: 8),
              Text('Rango de Fechas (máx. 6 meses)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          DateRangeWidget(
            title: 'Rango de Fechas (máx. 6 meses)',
            startDate: _fechaInicio,
            endDate: _fechaHasta,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
            onDateRangeSelected: (desde, hasta) {
              setState(() {
                if (desde != null && hasta != null) {
                  final diferencia = hasta.difference(desde);
                  final diasDiferencia = diferencia.inDays;
                  if (diasDiferencia > 180) {
                    _fechaHasta = desde.add(const Duration(days: 180));
                    if (_fechaHasta != null &&
                        _fechaHasta!.isAfter(DateTime.now())) {
                      _fechaHasta = DateTime.now();
                    }
                    SnackHelper.show(
                      context,
                      message: 'El rango máximo es de 6 meses',
                      isError: true,
                    );
                  } else {
                    _fechaInicio = desde;
                    _fechaHasta = hasta;
                  }
                  if (_fechaHasta != null &&
                      _fechaHasta!.isAfter(DateTime.now())) {
                    _fechaHasta = DateTime.now();
                  }
                } else {
                  _fechaInicio = desde;
                  _fechaHasta = hasta;
                }
              });
            },
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Buscar',
            icon: Icons.search,
            onPressed: _cargarDatos,
            colorButton: ThemeApp.primary,
            colorText: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildListaUsuarios() {
    if (_usuarios.isEmpty) {
      return const NotFoundCard(
          message: 'No se encontraron usuarios en el período seleccionado',
          icon: Icons.people_outline);
    }

    return ReporteDataTableWidget(
      titulo: 'Tabla de Usuarios',
      icono: Icons.table_chart,
      mensajeVacio: 'No se encontraron usuarios en el período seleccionado',
      columns: const [
        DataColumn(
          label: Text(
            'ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Nombres',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Apellidos',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Identificación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Correo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Teléfono',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Fecha Creación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: _usuarios.map((usuario) {
        final persona = _personasMap[usuario.identificacion];
        return DataRow(
          cells: [
            DataCell(Text('${usuario.idUsuario}')),
            DataCell(Text(persona?.nombres ?? 'N/A')),
            DataCell(Text(persona?.apellidos ?? 'N/A')),
            DataCell(Text(usuario.identificacion)),
            DataCell(Text(persona?.correo ?? 'N/A')),
            DataCell(Text(persona?.telefono ?? 'N/A')),
            DataCell(Text(
              usuario.fCreacion != null
                  ? AppUtils.formatDate(usuario.fCreacion)
                  : 'N/A',
            )),
          ],
        );
      }).toList(),
    );
  }
}
