import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';

class ProductosMasVendidos extends StatelessWidget {
  final List<VentaEntity> ventasHoy;

  const ProductosMasVendidos({
    super.key,
    required this.ventasHoy,
  });

  @override
  Widget build(BuildContext context) {
    final productosVendidos = _calcularProductosVendidos();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos Más Vendidos',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(5),
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
          child: productosVendidos.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No hay productos vendidos hoy'),
                  ),
                )
              : Column(
                  children: productosVendidos.take(3).map((producto) {
                    return Card(
                        color: ThemeApp.background.withOpacity(0.9),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          spacing: 2,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 3),
                              child: _buildProductItem(
                                'Producto ${producto['id']}',
                                '${producto['cantidad']} vendidos',
                                '\$${producto['ingresos'].toStringAsFixed(2)}',
                              ),
                            )
                          ],
                        ));
                  }).toList(),
                ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _calcularProductosVendidos() {
    // Simulación de productos vendidos basado en las ventas
    // En una implementación real, necesitarías hacer JOIN con TDETALLEVENTA
    final productos = <Map<String, dynamic>>[];

    for (int i = 1; i <= 5; i++) {
      productos.add({
        'id': i,
        'cantidad': ventasHoy.length + i,
        'ingresos': (ventasHoy.length + i) * 15.0,
      });
    }

    productos.sort((a, b) => b['cantidad'].compareTo(a['cantidad']));
    return productos;
  }

  Widget _buildProductItem(String name, String quantity, String price) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: ThemeApp.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.restaurant,
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
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                quantity,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
