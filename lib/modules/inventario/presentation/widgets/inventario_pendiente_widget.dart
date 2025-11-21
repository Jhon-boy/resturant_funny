import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/modules/inventario/domain/repository/inventario_repository.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class InventarioPendienteWidget extends StatelessWidget {
  const InventarioPendienteWidget({
    super.key,
    required this.inventariosPendientes,
    required this.inventarioRepository,
    required this.onRefresh,
    this.isLoading = false,
  });

  final List<InventarioEntity> inventariosPendientes;
  final InventarioRepository inventarioRepository;
  final VoidCallback onRefresh;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && inventariosPendientes.isEmpty) {
      return ShimmerWidget.list(itemCount: 3);
    }

    if (inventariosPendientes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeApp.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeApp.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pending_actions,
                color: ThemeApp.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Inventarios Pendientes (${inventariosPendientes.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inventariosPendientes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final inventario = inventariosPendientes[index];
              return _InventarioPendienteCard(
                inventario: inventario,
                onAceptar: () => _handleAceptar(context, inventario),
                onRechazar: () => _handleRechazar(context, inventario),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleAceptar(
      BuildContext context, InventarioEntity inventario) async {
    DialogHelper.confirm(
      context,
      message: '¿Está seguro de aceptar el inventario "${inventario.nombre}"?',
      onConfirm: () async {
        Navigator.of(context).pop();  

        final result = await inventarioRepository
            .aceptarInventario(inventario.idInventario!);

        result.fold(
          (failure) {
            if (context.mounted) {
              DialogHelper.error(
                context,
                message: failure.message,
                onConfirmed: () {},
              );
            }
          },
          (updated) {
            if (context.mounted) {
              DialogHelper.success(
                context,
                message: 'Inventario aceptado correctamente',
                onConfirmed: () {
                  onRefresh();
                },
              );
            }
          },
        );
      },
      onCancel: () {},
    );
  }

  Future<void> _handleRechazar(
      BuildContext context, InventarioEntity inventario) async {
    DialogHelper.confirm(
      context,
      message:
          '¿Está seguro de rechazar el inventario "${inventario.nombre}"? Esta acción no se puede deshacer.',
      onConfirm: () async {
        Navigator.of(context).pop(); // Cerrar diálogo de confirmación

        final result = await inventarioRepository
            .rechazarInventario(inventario.idInventario!);

        result.fold(
          (failure) {
            if (context.mounted) {
              DialogHelper.error(
                context,
                message: failure.message,
                onConfirmed: () {},
              );
            }
          },
          (updated) {
            if (context.mounted) {
              DialogHelper.success(
                context,
                message: 'Inventario rechazado',
                onConfirmed: () {
                  onRefresh();
                },
              );
            }
          },
        );
      },
      onCancel: () {},
    );
  }
}

class _InventarioPendienteCard extends StatelessWidget {
  const _InventarioPendienteCard({
    required this.inventario,
    required this.onAceptar,
    required this.onRechazar,
  });

  final InventarioEntity inventario;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeApp.baseText,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información del inventario
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inventario.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ThemeApp.textPrimary,
                      ),
                    ),
                    if (inventario.descripcion != null &&
                        inventario.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        inventario.descripcion!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeApp.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (inventario.categoria != null)
                          _buildInfoChip(
                            Icons.category_outlined,
                            inventario.categoria!,
                            Colors.blue,
                          ),
                        if (inventario.stock != null)
                          _buildInfoChip(
                            Icons.inventory,
                            'Stock: ${inventario.stock}',
                            Colors.green,
                          ),
                        if (inventario.precioUnitario != null)
                          _buildInfoChip(
                            Icons.attach_money,
                            inventario.precioFormateado,
                            Colors.purple,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRechazar,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Rechazar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAceptar,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Aceptar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeApp.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
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
