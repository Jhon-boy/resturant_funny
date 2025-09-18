import 'package:flutter/material.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';

class ProductoCarouselWidget extends StatelessWidget {
  final List<ProductoEntity> productos;
  final void Function(ProductoEntity producto) onTap;

  const ProductoCarouselWidget({
    super.key,
    required this.productos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: productos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return _ProductoItem(
            producto: producto,
            onTap: () => onTap(producto),
          );
        },
      ),
    );
  }
}

class _ProductoItem extends StatelessWidget {
  final ProductoEntity producto;
  final VoidCallback onTap;

  const _ProductoItem({
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _fallbackNombre() {
    return Center(
      child: Text(
        producto.nombre,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
