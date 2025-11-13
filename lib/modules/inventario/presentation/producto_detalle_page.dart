import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';

class ProductoDetallePage extends StatelessWidget {
  const ProductoDetallePage({
    super.key,
    required this.producto,
    this.onEdit,
    this.onToggleDisponibilidad,
    this.onDelete,
  });

  final ProductoEntity producto;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onToggleDisponibilidad;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: producto.nombre,
      onBack: () => Navigator.of(context).pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImage(producto: producto),
            const SizedBox(height: 20),
            _InfoCard(
              producto: producto,
              onToggleDisponibilidad: onToggleDisponibilidad,
            ),
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

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.producto});

  final ProductoEntity producto;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: producto.tieneImagen
                ? Image.network(
                    producto.imagenUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(context),
                  )
                : _fallback(context),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: producto.isDisponible
                        ? ThemeApp.success.withOpacity(0.18)
                        : ThemeApp.error.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        producto.isDisponible
                            ? Icons.check_circle
                            : Icons.cancel_outlined,
                        size: 16,
                        color: producto.isDisponible
                            ? ThemeApp.success
                            : ThemeApp.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        producto.isDisponible ? 'Disponible' : 'No disponible',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: producto.isDisponible
                              ? ThemeApp.success
                              : ThemeApp.error,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: ThemeApp.inputBorder,
      alignment: Alignment.center,
      child: Text(
        producto.nombre,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.producto, this.onToggleDisponibilidad});

  final ProductoEntity producto;
  final Future<void> Function()? onToggleDisponibilidad;

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
          _InfoRow(label: 'Nombre', value: producto.nombre, icon: Icons.menu),
          const Divider(height: 24),
          _InfoRow(
              label: 'Descripción',
              value: producto.descripcion,
              icon: Icons.description),
          const Divider(height: 24),
          _InfoRow(
              label: 'Precio',
              value: producto.precioFormateado,
              icon: Icons.attach_money),
          const Divider(height: 24),
          _InfoRow(
              label: 'Categoría',
              value: producto.categoria,
              icon: Icons.category),
          const Divider(height: 24),
          _InfoRow(
            label: 'Sucursal',
            value: producto.idSucursal.toString(),
            icon: Icons.store,
          ),
          const Divider(height: 24),
          _InfoRow(
              label: 'F. Creación',
              value: AppUtils.formatDate(producto.fCreacion),
              icon: Icons.calendar_today),
          const Divider(height: 24),
          _InfoRow(
              label: 'F. Modificación',
              value: AppUtils.formatDate(producto.fModificacion),
              icon: Icons.calendar_today),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: ThemeApp.success),
                  SizedBox(width: 8),
                  Text('Disponibilidad'),
                ],
              ),
              Switch.adaptive(
                value: producto.isDisponible,
                onChanged: onToggleDisponibilidad != null
                    ? (value) async {
                        await onToggleDisponibilidad?.call();
                      }
                    : null,
                activeColor: ThemeApp.success,
                activeTrackColor: ThemeApp.success.withOpacity(0.18),
                inactiveThumbColor: ThemeApp.error,
                inactiveTrackColor: ThemeApp.error.withOpacity(0.18),
              ),
            ],
          ),
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
