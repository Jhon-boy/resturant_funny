import 'package:flutter/material.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';

class EstadisticasCards extends StatelessWidget {
  final List<VentaEntity> ventasHoy;
  final List<VentaEntity> ventasAyer;
  final List<VentaEntity> ventasAnteayer;

  const EstadisticasCards({
    super.key,
    required this.ventasHoy,
    required this.ventasAyer,
    required this.ventasAnteayer,
  });

  @override
  Widget build(BuildContext context) {
    final estadisticasHoy = _calcularEstadisticas(ventasHoy);
    final estadisticasAyer = _calcularEstadisticas(ventasAyer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen del Día',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              Widget card;
              switch (index) {
                case 0:
                  card = _buildStatCard(
                    context,
                    'Ventas',
                    '${estadisticasHoy['totalVentas']}',
                    Icons.point_of_sale,
                    Colors.green,
                    _calcularPorcentajeCambio(
                      estadisticasHoy['totalVentas'].toDouble(),
                      estadisticasAyer['totalVentas'].toDouble(),
                    ),
                  );
                  break;
                case 1:
                  card = _buildStatCard(
                    context,
                    'Ingresos',
                    '\$${estadisticasHoy['ingresos'].toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.blue,
                    _calcularPorcentajeCambio(
                      estadisticasHoy['ingresos'].toDouble(),
                      estadisticasAyer['ingresos'].toDouble(),
                    ),
                  );
                  break;
                case 2:
                  card = _buildStatCard(
                    context,
                    'Promedio',
                    '\$${estadisticasHoy['promedioVenta'].toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.orange,
                    _calcularPorcentajeCambio(
                      estadisticasHoy['promedioVenta'].toDouble(),
                      estadisticasAyer['promedioVenta'].toDouble(),
                    ),
                  );
                  break;
                case 3:
                  card = _buildStatCard(
                    context,
                    'Mesas',
                    '${estadisticasHoy['mesasAtendidas']}',
                    Icons.table_restaurant,
                    Colors.purple,
                    _calcularPorcentajeCambio(
                      estadisticasHoy['mesasAtendidas'].toDouble(),
                      estadisticasAyer['mesasAtendidas'].toDouble(),
                    ),
                  );
                  break;
                default:
                  card = const SizedBox();
              }
              return Padding(
                padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
                child: card,
              );
            },
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _calcularEstadisticas(List<VentaEntity> ventas) {
    debugPrint('Calculando estadísticas para ${ventas.length} ventas');

    for (int i = 0; i < ventas.length; i++) {
      debugPrint(
          'Venta $i: Estado = "${ventas[i].estado}", Total = ${ventas[i].total}');
    }

    final ventasCompletadas =
        ventas.where((v) => v.estado == 'FINALIZADA').toList();
    debugPrint('Ventas completadas: ${ventasCompletadas.length}');

    final totalVentas = ventasCompletadas.length;
    final ingresos = ventasCompletadas.fold<double>(
      0.0,
      (sum, venta) => sum + (venta.total ?? 0.0),
    );
    final promedioVenta = totalVentas > 0 ? ingresos / totalVentas : 0.0;
    final mesasAtendidas =
        ventasCompletadas.map((v) => v.idMesa).toSet().length;

    return {
      'totalVentas': totalVentas,
      'ingresos': ingresos,
      'promedioVenta': promedioVenta,
      'mesasAtendidas': mesasAtendidas,
    };
  }

  String _calcularPorcentajeCambio(double hoy, double ayer) {
    if (ayer == 0) return hoy > 0 ? '+100%' : '0%';
    final cambio = ((hoy - ayer) / ayer) * 100;
    final signo = cambio >= 0 ? '+' : '';
    return '$signo${cambio.toStringAsFixed(0)}% vs ayer';
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      width: 140,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Icon(
                subtitle.contains('+')
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: subtitle.contains('+') ? Colors.green : Colors.red,
                size: 12,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: subtitle.contains('+') ? Colors.green : Colors.red,
                      fontSize: 9,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
