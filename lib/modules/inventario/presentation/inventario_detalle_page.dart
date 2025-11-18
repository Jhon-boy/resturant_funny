import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';

class InventarioDetallePage extends StatelessWidget {
  const InventarioDetallePage({
    super.key,
    required this.inventario,
    this.onEdit,
    this.onDelete,
  });

  final InventarioEntity inventario;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: inventario.nombre,
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(inventario: inventario),
            const SizedBox(height: 20),
            _InfoCard(inventario: inventario),
            const SizedBox(height: 16),
            Row(
              children: [
                if (onEdit != null) ...[
                  Expanded(
                    child: CustomButton(
                      icon: Icons.edit,
                      text: 'Editar',
                      onPressed: () async {
                        await onEdit?.call();
                      },
                    ),
                  ),
                ],
                if (onDelete != null) ...[
                  if (onEdit != null) const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      icon: Icons.delete_outline,
                      text: 'Eliminar',
                      colorButton: ThemeApp.error,
                      colorText: Colors.white,
                      onPressed: () async {
                        await onDelete?.call();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.inventario});

  final InventarioEntity inventario;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeApp.primary.withOpacity(0.8),
            ThemeApp.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeApp.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.inventory_2,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        inventario.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: inventario.isActivo
                            ? Colors.white.withOpacity(0.25)
                            : Colors.red.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            inventario.isActivo
                                ? Icons.check_circle
                                : Icons.cancel_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            inventario.isActivo ? 'Activo' : 'Inactivo',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _StatItem(
                      icon: Icons.inventory,
                      label: 'Stock',
                      value: inventario.stockFormateado,
                    ),
                    const SizedBox(width: 24),
                    _StatItem(
                      icon: Icons.attach_money,
                      label: 'Precio',
                      value: inventario.precioFormateado,
                    ),
                    const SizedBox(width: 24),
                    _StatItem(
                      icon: Icons.calculate,
                      label: 'Valor Total',
                      value: inventario.valorTotalFormateado,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.inventario});

  final InventarioEntity inventario;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
              label: 'Nombre', value: inventario.nombre, icon: Icons.label),
          const Divider(height: 24),
          _InfoRow(
              label: 'Descripción',
              value: inventario.descripcion ?? 'Sin descripción',
              icon: Icons.description),
          const Divider(height: 24),
          _InfoRow(
              label: 'Categoría',
              value: inventario.categoria ?? 'Sin categoría',
              icon: Icons.category),
          const Divider(height: 24),
          _InfoRow(
              label: 'Stock disponible',
              value: inventario.stockFormateado,
              icon: Icons.inventory),
          const Divider(height: 24),
          _InfoRow(
              label: 'Precio unitario',
              value: inventario.precioFormateado,
              icon: Icons.attach_money),
          const Divider(height: 24),
          _InfoRow(
              label: 'Valor total',
              value: inventario.valorTotalFormateado,
              icon: Icons.calculate),
          const Divider(height: 24),
          _InfoRow(
            label: 'Sucursal',
            value: inventario.idSucursal.toString(),
            icon: Icons.store,
          ),
          const Divider(height: 24),
          _InfoRow(
              label: 'Estado',
              value: inventario.estadoFormateado,
              icon: Icons.info),
          const Divider(height: 24),
          _InfoRow(
              label: 'F. Creación',
              value: AppUtils.formatDate(inventario.fCreacion),
              icon: Icons.calendar_today),
          const Divider(height: 24),
          _InfoRow(
              label: 'F. Modificación',
              value: AppUtils.formatDate(inventario.fModificacion),
              icon: Icons.calendar_today),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: ThemeApp.textSecondary),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ThemeApp.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ThemeApp.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
