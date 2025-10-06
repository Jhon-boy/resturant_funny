import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';

class VentasRecientes extends StatelessWidget {
  final List<VentaEntity> ventasHoy;

  const VentasRecientes({
    super.key,
    required this.ventasHoy,
  });

  @override
  Widget build(BuildContext context) {
    final ventasRecientes = ventasHoy.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ventas Recientes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                    final index = entry.key;
                    final venta = entry.value;
                    return Column(
                      children: [
                        if (index > 0) const Divider(height: 20),
                        _buildSaleItem(
                          'Mesa ${venta.idMesa}',
                          _formatTime(venta.fecha),
                          '\$${(venta.total ?? 0.0).toStringAsFixed(2)}',
                          venta.estado ?? 'Pendiente',
                        ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? fecha) {
    if (fecha == null) return 'N/A';
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildSaleItem(String mesa, String time, String amount, String status) {
    Color statusColor = status == 'COMPLETADA' ? Colors.green : Colors.orange;
    
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ThemeApp.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.table_restaurant,
            color: ThemeApp.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mesa,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      ],
    );
  }
}