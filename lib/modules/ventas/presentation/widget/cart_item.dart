
import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';

class CartItem {
  final ProductoEntity producto;
  int cantidad;
  CartItem({required this.producto, required this.cantidad});
}

class CardSeccion extends StatelessWidget {
  final String title;
  final Widget child;
  const CardSeccion({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ThemeApp.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class MiniImagen extends StatelessWidget {
  final ProductoEntity producto;
  const MiniImagen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        producto.imagen ?? "",
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[300],
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported, size: 20),
        ),
      ),
    );
  }
}
