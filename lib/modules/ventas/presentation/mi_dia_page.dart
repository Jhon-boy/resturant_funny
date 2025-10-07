import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
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

  Future<void> _cargarEstadisticas() async {
    setState(() => _isLoading = true);

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
        (failure) => debugPrint('Error cargando ventas hoy: $failure'),
        (ventas) => setState(() => _ventasHoy = ventas),
      );

      ventasAyerResult.fold(
        (failure) => debugPrint('Error cargando ventas ayer: $failure'),
        (ventas) => setState(() => _ventasAyer = ventas),
      );

      ventasAnteayerResult.fold(
        (failure) => debugPrint('Error cargando ventas anteayer: $failure'),
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
        (_) {},
        (cards) => setState(() => _ventasLista = cards),
      );
    } catch (e) {
      debugPrint('Error cargando estadísticas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarVentasPorCliente(String identificacion) async {
    debugPrint('Filtro: $identificacion');
    try {
      final cards = await _ventasRepository.getVentasByUsuario(identificacion);
      cards.fold(
        (_) {
          SnackHelper.show(context,
              message: 'No se encontraron ventas', isError: true);
        },
        (cards) => setState(() => _ventasLista = cards),
      );
    } catch (e) {
      debugPrint('Error buscando ventas por cliente: $e');
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: CustomButton(
                        colorButton: _index == 0
                            ? ThemeApp.primary
                            : ThemeApp.inputBorder,
                        text: "Estadisticas",
                        onPressed: () {
                          setState(() => _index = 0);
                        })),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomButton(
                        colorButton: _index == 1
                            ? ThemeApp.primary
                            : ThemeApp.inputBorder,
                        text: "Ventas",
                        onPressed: () {
                          setState(() => _index = 1);
                        })),
                const SizedBox(width: 10),
                Expanded(
                    child: CustomButton(
                        colorButton: _index == 2
                            ? ThemeApp.primary
                            : ThemeApp.inputBorder,
                        text: "Productos",
                        onPressed: () {
                          setState(() => _index = 2);
                        }))
              ],
            ),
            const SizedBox(height: 15),
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
            const SizedBox(height: 5),
            if (_index == 0)
              EstadisticasCards(
                  ventasHoy: _ventasHoy,
                  ventasAyer: _ventasAyer,
                  ventasAnteayer: _ventasAnteayer),
            const SizedBox(height: 5),
            if (_index == 1)
              ProductosMasVendidos(
                ventasHoy: _ventasHoy,
              ),
            const SizedBox(height: 5),
            if (_index == 2) ...[
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
                    _buscarVentasPorCliente(_identificacionController.text);
                  });
                },
              ),
              const SizedBox(height: 8),
              VentasRecientes(
                ventas: _ventasLista,
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
