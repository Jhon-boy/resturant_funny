import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';

class ProductoCardWidget extends StatelessWidget {
  final ProductoEntity producto;
  final VoidCallback onTap;

  const ProductoCardWidget({
    super.key,
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              clipBehavior: Clip.antiAlias,
              child: producto.tieneImagen
                  ? Image.network(
                      producto.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackNombre(),
                    )
                  : _fallbackNombre(),
            ),
            const SizedBox(height: 8),
            Text(
              producto.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ThemeApp.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              producto.precioFormateado,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackNombre() {
    return Center(
      child: Text(
        producto.nombre,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
