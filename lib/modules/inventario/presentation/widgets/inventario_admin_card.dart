import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/shared/enums/categorias_producto.dart';

class InventarioAdminCard extends StatelessWidget {
  const InventarioAdminCard({
    super.key,
    required this.inventario,
    this.onTap,
  });

  final InventarioEntity inventario;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeApp.cardColors,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            color: ThemeApp.baseText,
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
                width: MediaQuery.of(context).size.width * 0.25,
                height: double.infinity,
                child: _InventarioThumbnail(inventario: inventario),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Text(
                        inventario.nombre,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ThemeApp.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Stock: ${inventario.stock}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ThemeApp.success,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ThemeApp.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Precio U.: ${inventario.precioFormateado}',
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

class _InventarioThumbnail extends StatelessWidget {
  const _InventarioThumbnail({required this.inventario});

  final InventarioEntity inventario;

  IconData _getIconFromCategoria() {
    if (inventario.categoria == null || inventario.categoria!.isEmpty) {
      debugPrint('categoria is null');
      return Icons.inventory_2_outlined;
    }

    try {
      if (ProductosCategorias.allCodes.contains(inventario.categoria)) {
        debugPrint('categoria is not ${inventario.categoria}');
        return ProductosCategorias.getIconFromCode(inventario.categoria!);
      }
    } catch (e) {
      // Si hay algún error, retornar el icono por defecto
    }
    debugPrint('categoria is not found');
    return Icons.inventory_2_outlined;
  }

  Color _getColorFromCategoria() {
    if (inventario.categoria == null || inventario.categoria!.isEmpty) {
      return Colors.grey;
    }

    try {
      if (ProductosCategorias.allCodes.contains(inventario.categoria)) {
        return ProductosCategorias.getColorFromCode(inventario.categoria!);
      }
    } catch (e) {
      // Si hay algún error, retornar el color por defecto
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final categoriaColor = _getColorFromCategoria();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: categoriaColor.withOpacity(0.15),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getIconFromCategoria(),
                  size: 32,
                  color: categoriaColor,
                ),
                const SizedBox(height: 4),
                Text(
                  inventario.nombre,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: categoriaColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
