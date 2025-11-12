import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';

class ProductoAdminCard extends StatelessWidget {
  const ProductoAdminCard({
    super.key,
    required this.producto,
    this.onTap,
  });

  final ProductoEntity producto;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 86,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                height: double.infinity,
                child: _ProductoThumbnail(producto: producto),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Text(
                        producto.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: ThemeApp.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _DisponibilidadChip(
                            isDisponible: producto.isDisponible),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ThemeApp.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            producto.precioFormateado,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ThemeApp.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.arrow_forward_ios,
                      size: 20, color: ThemeApp.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductoThumbnail extends StatelessWidget {
  const _ProductoThumbnail({required this.producto});

  final ProductoEntity producto;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.black12),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Text(
          producto.nombre,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ThemeApp.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DisponibilidadChip extends StatelessWidget {
  const _DisponibilidadChip({required this.isDisponible});

  final bool isDisponible;

  @override
  Widget build(BuildContext context) {
    final color = isDisponible ? ThemeApp.success : ThemeApp.error;
    final label = isDisponible ? 'Disponible' : 'No disponible';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDisponible ? Icons.check_circle : Icons.cancel_outlined,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
