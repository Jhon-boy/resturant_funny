import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/estadisticas_cards.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/estadisticas_header.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/productos_mas_vendidos.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/ventas_recientes.dart';
import 'package:resturant_funny/modules/ventas/domain/models/venta_card_model.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';
import 'package:resturant_funny/shared/widgets/input_search_widget.dart';

class MiDiaPage extends ConsumerStatefulWidget {
  const MiDiaPage({super.key});

  @override
  ConsumerState<MiDiaPage> createState() => _MiDiaPageState();
}

class _MiDiaPageState extends ConsumerState<MiDiaPage> {
  bool _isLoading = true;
  List<VentaEntity> _ventasHoy = [];
  List<VentaEntity> _ventasAyer = [];
  List<VentaEntity> _ventasAnteayer = [];
  List<VentaCardModel> _ventasLista = [];
  List<VentaCardModel> _ventasClientes = [];
  int _index = 0;
  late final VentaRepository _ventasRepository;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _identificacionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _ventasRepository = VentaRepositoryImpl(VentasRemoteDataSource(ref: ref));
    _cargarEstadisticas();
    _index = 0;
  }

  final List<String> _botones = [
    'Estadísticas',
    'Ventas',
    'Productos',
    'Clientes',
  ];

  clearData() {
    _ventasHoy = [];
    _ventasAyer = [];
    _ventasAnteayer = [];
    _ventasLista = [];
    _ventasClientes = [];
    setState(() {});
    debugPrint('Datos limpiados');
  }

  Future<void> _cargarEstadisticas() async {
    final appState = ref.watch(appStateProvider);
    appState.setLoading(true);
    clearData();

    try {
      final user = ref.read(userProvider).user;
      if (user?.idUsuario == null) return;

      final hoy = _selectedDate;
      final ayer = hoy.subtract(const Duration(days: 1));
      final anteayer = hoy.subtract(const Duration(days: 2));

      final ventasHoyResult = await _ventasRepository.getVentasBy(
        user!.idUsuario!,
        fechaDesde: DateTime(hoy.year, hoy.month, hoy.day),
        fechaHasta: DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59),
      );

      final ventasAyerResult = await _ventasRepository.getVentasBy(
        user.idUsuario!,
        fechaDesde: DateTime(ayer.year, ayer.month, ayer.day),
        fechaHasta: DateTime(ayer.year, ayer.month, ayer.day, 23, 59, 59),
      );

      final ventasAnteayerResult = await _ventasRepository.getVentasBy(
        user.idUsuario!,
        fechaDesde: DateTime(anteayer.year, anteayer.month, anteayer.day),
        fechaHasta:
            DateTime(anteayer.year, anteayer.month, anteayer.day, 23, 59, 59),
      );

      ventasHoyResult.fold(
        (failure) {
          debugPrint('Error cargando ventas hoy: $failure');
          setState(() => _ventasHoy = []);
        },
        (ventas) => setState(() => _ventasHoy = ventas),
      );

      ventasAyerResult.fold(
        (failure) {
          debugPrint('Error cargando ventas ayer: $failure');
          setState(() => _ventasAyer = []);
        },
        (ventas) => setState(() => _ventasAyer = ventas),
      );

      ventasAnteayerResult.fold(
        (failure) {
          debugPrint('Error cargando ventas anteayer: $failure');
          setState(() => _ventasAnteayer = []);
        },
        (ventas) => setState(() => _ventasAnteayer = ventas),
      );

      final diaDesde = DateTime(hoy.year, hoy.month, hoy.day);
      final diaHasta = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);

      final cardsEither = await _ventasRepository.getVentaCardsBy(
        user.idUsuario!,
        fechaDesde: diaDesde,
        fechaHasta: diaHasta,
      );
      cardsEither.fold(
        (_) => setState(() => _ventasLista = []),
        (cards) => setState(() => _ventasLista = cards),
      );
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
    } finally {
      appState.setLoading(false);
    }
  }

  Future<void> _buscarVentasPorCliente(String identificacion) async {
    debugPrint('Filtro: $identificacion');
    final appState = ref.watch(appStateProvider);
    try {
      appState.setLoading(true);
      final cards = await _ventasRepository.getVentasByUsuario(identificacion);
      cards.fold(
        (_) {
          SnackHelper.show(context,
              message: 'No se encontraron ventas', isError: true);
        },
        (cards) => {
          if (cards.isNotEmpty)
            {
              _identificacionController.clear(),
              setState(() => _ventasClientes = cards),
            }
          else
            {
              DialogHelper.error(context, message: 'No se encontraron ventas',
                  onConfirmed: () {
                _identificacionController.clear();
                setState(() => _ventasClientes = []);
              })
            }
        },
      );
    } catch (e) {
      debugPrint('Error buscando ventas por cliente: $e');
    } finally {
      appState.setLoading(false);
    }
  }

  @override
  void dispose() {
    _identificacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading ? _buildShimmerLoading() : _buildContent(),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _cargarEstadisticas,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EstadisticasHeader(
              onRefresh: _cargarEstadisticas,
            ),
            const SizedBox(height: 24),
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
                        onSelected: (_) => setState(() => _index = i),
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
            const SizedBox(height: 15),
            if (_index != 3) ...[
              CalendarWidget(
                title: 'Fecha',
                selectedDate: _selectedDate,
                onDateSelected: (date) async {
                  if (date != null) {
                    setState(() => _selectedDate = date);
                    await _cargarEstadisticas();
                  }
                },
              ),
            ],
            const SizedBox(height: 5),
            if (_index == 0) ...[
              EstadisticasCards(
                  ventasHoy: _ventasHoy,
                  ventasAyer: _ventasAyer,
                  ventasAnteayer: _ventasAnteayer),
              const SizedBox(height: 5),
              ProductosMasVendidos(
                ventasHoy: _ventasHoy,
              ),
            ],
            const SizedBox(height: 5),
            if (_index == 2) ...[
              const SizedBox(height: 8),
              VentasRecientes(
                ventas: _ventasLista,
                isClientes: false,
              ),
            ],
            if (_index == 3) ...[
              InputSearchWidget(
                label: 'Buscar',
                hint: 'Ej: 0102030405',
                showSuffixButton: false,
                onSubmitted: (value) async {
                  _identificacionController.text = value;
                  _buscarVentasPorCliente(_identificacionController.text);
                },
                onChanged: (value) {
                  setState(() {
                    _identificacionController.text = value;
                    //  _buscarVentasPorCliente(_identificacionController.text);
                  });
                },
              ),
              VentasRecientes(
                ventas: _ventasClientes,
                isClientes: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(
            width: double.infinity,
            height: 120,
            borderRadius: 16,
          ),
          const SizedBox(height: 24),
          Text(
            'Resumen del Día',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
                child: _shimmerBox(
                  width: 160,
                  height: 200,
                  borderRadius: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Productos Más Vendidos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _shimmerBox(
            width: double.infinity,
            height: 200,
            borderRadius: 12,
          ),
          const SizedBox(height: 24),
          Text(
            'Ventas Recientes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _shimmerBox(
            width: double.infinity,
            height: 180,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double borderRadius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
