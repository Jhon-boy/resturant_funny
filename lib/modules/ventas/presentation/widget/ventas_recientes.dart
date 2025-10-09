import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/ventas/domain/models/venta_card_model.dart';

class VentasRecientes extends StatelessWidget {
  final List<VentaCardModel> ventas;
  final bool isClientes;

  const VentasRecientes({
    super.key,
    required this.ventas,
    this.isClientes = false,
  });

  @override
  Widget build(BuildContext context) {
    final ventasRecientes = ventas.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isClientes)
          const SizedBox(
            height: 10,
          ),
        Text(
          isClientes ? 'Historial de ventas del cliente' : 'Ventas del día',
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
                          venta.nombreProducto ?? 'Producto',
                          venta.nombreCliente,
                          '\$${venta.total.toStringAsFixed(2)}',
                          venta.estado ?? 'Pendiente',
                          cantidad: venta.cantidadProducto,
                        ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildSaleItem(
      String producto, String cliente, String amount, String status,
      {int? cantidad}) {
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
            Icons.receipt_long,
            color: ThemeApp.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(producto,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(cliente,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
            if (cantidad != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeApp.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('x$cantidad',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: ThemeApp.primary)),
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
