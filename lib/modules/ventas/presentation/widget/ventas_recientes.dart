import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/data/repository/ventas_repository_impl.dart';
import 'package:resturant_funny/modules/ventas/domain/models/venta_card_model.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/ventas_detail_card.dart';

class VentasRecientes extends ConsumerStatefulWidget {
  final List<VentaCardModel> ventas;
  final bool isClientes;
  final String title;

  const VentasRecientes({
    super.key,
    required this.ventas,
    this.isClientes = false,
    required this.title,
  });

  @override
  ConsumerState<VentasRecientes> createState() => _VentasRecientesState();
}

class _VentasRecientesState extends ConsumerState<VentasRecientes> {
  late final VentaRepository _ventasRepository;
  @override
  void initState() {
    super.initState();
    _ventasRepository = VentaRepositoryImpl(VentasRemoteDataSource(ref: ref));
  }

  Future<void> _buscarVentasPorIdentificador(int idVenta) async {
    debugPrint('Buscando venta ID: $idVenta');
    try {
      final result = await _ventasRepository.getVentaById(idVenta);
      result.fold(
        (failure) {
          debugPrint('Error buscando venta: $failure');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al cargar los detalles')),
            );
          }
        },
        (venta) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return VentaDetailCard(
                  venta: venta,
                  initiallyExpanded: true,
                  showInDialog: true,
                );
              },
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Error buscando venta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ventasRecientes = widget.ventas.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isClientes)
          const SizedBox(
            height: 10,
          ),
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: ThemeApp.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ventasRecientes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No hay ventas recientes'),
                  ),
                )
              : Column(
                  children: ventasRecientes.asMap().entries.map((entry) {
                    final venta = entry.value;
                    return Card(
                        color: ThemeApp.cardColors,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          spacing: 2,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(3),
                              child: _buildSaleItem(venta),
                            ),
                          ],
                        ));
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildSaleItem(VentaCardModel venta) {
    final status = venta.estado ?? 'Pendiente';
    Color statusColor = AppUtils.getStatusColor(status);

    return InkWell(
      onTap: () => _buscarVentasPorIdentificador(venta.idVenta),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ThemeApp.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: ThemeApp.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venta.nombreProducto ?? 'Producto',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    venta.nombreCliente,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${venta.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (venta.cantidadProducto != null)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ThemeApp.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'x${venta.cantidadProducto}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ThemeApp.primary,
                      ),
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
