import 'package:flutter/material.dart';

class GraficoVentasWidget extends StatelessWidget {
  final List<VentaDia> ventasPorDia;
  final double maxVentas;

  const GraficoVentasWidget({
    super.key,
    required this.ventasPorDia,
    required this.maxVentas,
  });

  @override
  Widget build(BuildContext context) {
    if (ventasPorDia.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Ventas por Día',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ventasPorDia.map((ventaDia) {
                final altura = maxVentas > 0
                    ? (ventaDia.numeroVentas / maxVentas * 100)
                    : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${ventaDia.numeroVentas}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: altura / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.9),
                                      Colors.white.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ventaDia.dia,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class VentaDia {
  final String dia;
  final int numeroVentas;
  final double montoTotal;

  VentaDia({
    required this.dia,
    required this.numeroVentas,
    required this.montoTotal,
  });
}
