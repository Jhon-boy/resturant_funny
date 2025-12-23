import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/ventas/domain/models/producto_mas_vendido_model.dart';

class ProductosMasVendidos extends StatelessWidget {
  final List<ProductoMasVendidoModel> productos;

  const ProductosMasVendidos({
    super.key,
    required this.productos,
  });

  @override
  Widget build(BuildContext context) {
    final productosVendidos = [...productos]..sort(
        (a, b) => b.cantidadVendida.compareTo(a.cantidadVendida),
      );

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
                    child: Text(
                        'No hay datos de productos vendidos en los últimos meses'),
                  ),
                )
              : Column(
                  children: productosVendidos.take(3).map((producto) {
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 3),
                              child: _buildProductItem(
                                producto.nombreProducto,
                                '${producto.cantidadVendida} vendidos',
                                '\$${producto.ingresosTotales.toStringAsFixed(2)}',
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
