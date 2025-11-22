import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/reportes/domain/models/estadisticas_ventas_model.dart';

/// Widget para mostrar gráfico de ventas por día con montos
class GraficoVentasCompletoWidget extends StatelessWidget {
  final List<VentaDiaStats> ventasPorDia;
  final bool mostrarMontos;

  const GraficoVentasCompletoWidget({
    super.key,
    required this.ventasPorDia,
    this.mostrarMontos = true,
  });

  @override
  Widget build(BuildContext context) {
    if (ventasPorDia.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxVentas =
        ventasPorDia.map((v) => v.numeroVentas).reduce((a, b) => a > b ? a : b);
    final maxMonto =
        ventasPorDia.map((v) => v.montoTotal).reduce((a, b) => a > b ? a : b);

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
          const Row(
            children: [
              Icon(Icons.bar_chart, color: ThemeApp.primary, size: 24),
              SizedBox(width: 12),
              Text(
                'Ventas por Día',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ventasPorDia.map((ventaDia) {
                final alturaVentas = maxVentas > 0
                    ? (ventaDia.numeroVentas / maxVentas * 200)
                    : 0.0;
                final alturaMonto =
                    maxMonto > 0 ? (ventaDia.montoTotal / maxMonto * 200) : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (mostrarMontos)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '\$${ventaDia.montoTotal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: ThemeApp.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${ventaDia.numeroVentas}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ThemeApp.primary,
                            ),
                          ),
                        ),
                        if (ventaDia.numeroFacturas > 0) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${ventaDia.numeroFacturas} fact.',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple.shade700,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  ThemeApp.primary,
                                  ThemeApp.primary.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                            height: mostrarMontos ? alturaMonto : alturaVentas,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ventaDia.dia,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: ThemeApp.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Ventas', ThemeApp.primary),
              if (mostrarMontos)
                _buildLegendItem('Montos', ThemeApp.primary.withOpacity(0.6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: ThemeApp.textSecondary,
          ),
        ),
      ],
    );
  }
}
