// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/data/datasource/sesion_remote_data_source.dart';
import 'package:resturant_funny/modules/authentication/data/repository/sesion_repository_impl.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/sesion_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/repository/sesion_repository.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/estadisticas_basicas_widget.dart';
import 'package:resturant_funny/modules/reportes/presentation/widgets/reporte_data_table_widget.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/widgets/not_found_card.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';

class ReportesSesionPage extends ConsumerStatefulWidget {
  const ReportesSesionPage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<ReportesSesionPage> createState() => _ReportesSesionPageState();
}

class _ReportesSesionPageState extends ConsumerState<ReportesSesionPage> {
  late SesionRepository _sesionRepository;

  // Filtros de fecha
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  List<SesionEntity> _sesiones = [];
  int _totalSesiones = 0;
  int _sesionesActivas = 0;
  int _sesionesExpiradas = 0;
  int _sesionesInactivas = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sesionRepository = SessionRepositoryImpl(
        SessionRemoteDataSource(ref: ref),
      );
      _fechaHasta = DateTime.now();
      _fechaDesde = _fechaHasta!.subtract(const Duration(days: 7));
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    if (_fechaDesde == null || _fechaHasta == null) {
      setState(() {
        _sesiones = [];
        _totalSesiones = 0;
        _sesionesActivas = 0;
        _sesionesExpiradas = 0;
        _sesionesInactivas = 0;
      });
      return;
    }

    ref.read(appStateProvider.notifier).setLoading(true);

    try {
      final sesionesResult = await _sesionRepository.getAllSesiones(
        _fechaDesde,
        _fechaHasta,
      );

      sesionesResult.fold(
        (failure) {
          DialogHelper.error(context,
              message: failure.message, onConfirmed: () {});
          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        (sesiones) {
          // Calcular estadísticas
          _totalSesiones = sesiones.length;
          _sesionesActivas = sesiones.where((s) => s.isActiva).length;
          _sesionesExpiradas = sesiones.where((s) => s.isExpirada).length;
          _sesionesInactivas = sesiones.where((s) => s.activo == false).length;

          setState(() {
            _sesiones = sesiones;
          });

          if (mounted) {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
      );
    } catch (e) {
      DialogHelper.error(context,
          message: 'Error inesperado: $e', onConfirmed: () {});
      if (mounted) {
        ref.read(appStateProvider.notifier).setLoading(false);
      }
    }
  }

  void _generarPDF() {
    DialogHelper.info(context,
        message: 'Generación de PDF próximamente', onConfirmed: () {});
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: widget.title,
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

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateRangeWidget(
            title: 'Rango de Fechas (máx. 3 meses)',
            startDate: _fechaDesde,
            endDate: _fechaHasta,
            firstDate: DateTime.now().subtract(const Duration(days: 90)),
            lastDate: DateTime.now(),
            onDateRangeSelected: (desde, hasta) {
              setState(() {
                if (desde != null && hasta != null) {
                  final diferencia = hasta.difference(desde);
                  final diasDiferencia = diferencia.inDays;
                  if (diasDiferencia > 90) {
                    _fechaHasta = desde.add(const Duration(days: 90));
                    if (_fechaHasta != null &&
                        _fechaHasta!.isAfter(DateTime.now())) {
                      _fechaHasta = DateTime.now();
                    }
                    SnackHelper.show(
                      context,
                      message: 'El rango máximo es de 3 meses',
                      isError: true,
                    );
                  } else {
                    _fechaDesde = desde;
                    _fechaHasta = hasta;
                  }
                  if (_fechaHasta != null &&
                      _fechaHasta!.isAfter(DateTime.now())) {
                    _fechaHasta = DateTime.now();
                  }
                } else {
                  _fechaDesde = desde;
                  _fechaHasta = hasta;
                }
              });
              _cargarDatos();
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Mostrando sesiones de los últimos ${_fechaHasta != null && _fechaDesde != null ? _fechaHasta!.difference(_fechaDesde!).inDays : 0} días',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoReporte() {
    return ref.watch(appStateProvider).isLoading
        ? Center(child: ShimmerWidget.list(itemCount: 3))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstadisticasBasicas(),
              const SizedBox(height: 24),
              _buildListaSesiones(),
            ],
          );
  }

  Widget _buildEstadisticasBasicas() {
    return EstadisticasBasicasWidget(
      titulo: 'Estadísticas de Sesiones',
      icono: Icons.analytics_outlined,
      estadisticas: [
        EstadisticaBasica(
          titulo: 'Total Sesiones',
          valor: '$_totalSesiones',
          icon: Icons.login,
          color: Colors.blue,
        ),
        EstadisticaBasica(
          titulo: 'Activas',
          valor: '$_sesionesActivas',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        EstadisticaBasica(
          titulo: 'Expiradas',
          valor: '$_sesionesExpiradas',
          icon: Icons.schedule,
          color: Colors.orange,
        ),
        EstadisticaBasica(
          titulo: 'Inactivas',
          valor: '$_sesionesInactivas',
          icon: Icons.pause_circle,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildListaSesiones() {
    if (_sesiones.isEmpty) {
      return const NotFoundCard(
        message:
            'No se encontraron sesiones en el rango de fechas seleccionado',
        icon: Icons.login_outlined,
      );
    }

    return ReporteDataTableWidget(
      titulo: 'Tabla de Sesiones',
      icono: Icons.table_chart,
      mensajeVacio: 'No se encontraron sesiones',
      columns: const [
        DataColumn(
          label: Text(
            'Usuario',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Fecha Creación',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Fecha Expiración',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Token',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Tiempo Restante',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Estado',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: _sesiones.map((sesion) {
        Color estadoColor;
        switch (sesion.estadoSesion) {
          case 'ACTIVA':
            estadoColor = Colors.green;
            break;
          case 'EXPIRADA':
            estadoColor = Colors.orange;
            break;
          case 'INACTIVA':
            estadoColor = Colors.grey;
            break;
          default:
            estadoColor = Colors.grey;
        }

        return DataRow(
          cells: [
            DataCell(Text('ID: ${sesion.idUsuario}')),
            DataCell(Text(AppUtils.formatDate(sesion.fCreacion))),
            DataCell(Text(AppUtils.formatDate(sesion.fExpiracion))),
            DataCell(Text(sesion.tokenTruncado)),
            DataCell(Text(sesion.tiempoRestanteFormateado)),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  sesion.estadoSesion,
                  style: TextStyle(
                    color: estadoColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
