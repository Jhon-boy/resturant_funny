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
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 10,
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
                        _StockChip(stock: inventario.stock),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ThemeApp.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            inventario.precioFormateado,
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

class _StockChip extends StatelessWidget {
  const _StockChip({required this.stock});

  final int? stock;

  @override
  Widget build(BuildContext context) {
    final stockValue = stock ?? 0;
    final color = stockValue > 0
        ? (stockValue < 10 ? Colors.orange : ThemeApp.success)
        : ThemeApp.error;
    final label = stockValue > 0
        ? (stockValue < 10 ? 'Stock bajo' : 'En stock')
        : 'Sin stock';

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
            stockValue > 0
                ? (stockValue < 10 ? Icons.warning_amber : Icons.check_circle)
                : Icons.cancel_outlined,
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
