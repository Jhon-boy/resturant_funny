import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

/// Modelo para representar una estadística individual
class EstadisticaBasica {
  final String titulo;
  final String valor;
  final IconData icon;
  final Color color;

  const EstadisticaBasica({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.color,
  });
}

/// Widget reutilizable para mostrar estadísticas básicas en formato de grid
class EstadisticasBasicasWidget extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<EstadisticaBasica> estadisticas;
  final int crossAxisCount;
  final double childAspectRatio;

  const EstadisticasBasicasWidget({
    super.key,
    required this.titulo,
    this.icono = Icons.info_outline,
    required this.estadisticas,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(icono, color: ThemeApp.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeApp.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
            children: estadisticas.map((estadistica) {
              return _EstadisticaCard(
                titulo: estadistica.titulo,
                valor: estadistica.valor,
                icon: estadistica.icon,
                color: estadistica.color,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Widget interno para las tarjetas de estadísticas individuales
class _EstadisticaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;
  final Color color;

  const _EstadisticaCard({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 10,
              color: ThemeApp.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
