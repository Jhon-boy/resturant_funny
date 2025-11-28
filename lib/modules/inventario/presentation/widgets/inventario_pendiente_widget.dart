import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/modules/inventario/domain/repository/inventario_repository.dart';
import 'package:resturant_funny/modules/user/presentation/widget/shimmer_widget.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';
import 'package:resturant_funny/shared/enums/categorias_producto.dart';

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

  Future<void> _handleAceptar(
      BuildContext context, InventarioEntity inventario) async {
    DialogHelper.confirm(
      context,
      message: '¿Está seguro de aceptar el inventario "${inventario.nombre}"?',
      onConfirm: () async {
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
        color: ThemeApp.cardColors,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeApp.inputBorder,
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
            separatorBuilder: (context, index) => const SizedBox(height: 12),
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
}

class _InventarioPendienteCard extends StatefulWidget {
  const _InventarioPendienteCard({
    required this.inventario,
    required this.onAceptar,
    required this.onRechazar,
  });

  final InventarioEntity inventario;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  @override
  State<_InventarioPendienteCard> createState() =>
      _InventarioPendienteCardState();
}

class _InventarioPendienteCardState extends State<_InventarioPendienteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeApp.baseText,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: ThemeApp.baseText,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: ThemeApp.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: 100,
                    child: _InventarioThumbnail(inventario: widget.inventario),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.inventario.nombre,
                          maxLines: _isExpanded ? null : 2,
                          overflow: _isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ThemeApp.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Stock: ${widget.inventario.stock ?? 0}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeApp.success,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ThemeApp.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Precio U.: ${widget.inventario.precioFormateado}',
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
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: ThemeApp.textSecondary,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                if (widget.inventario.descripcion != null &&
                    widget.inventario.descripcion!.isNotEmpty) ...[
                  Text(
                    widget.inventario.descripcion!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeApp.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildInfoRow(
                    'Categoría', widget.inventario.categoria ?? 'N/A'),
                _buildInfoRow(
                    'Valor Total', widget.inventario.valorTotalFormateado),
                _buildInfoRow('Estado', widget.inventario.estadoFormateado),
                if (widget.inventario.fCreacion != null)
                  _buildInfoRow('Fecha Solicitud',
                      AppUtils.formatDate(widget.inventario.fCreacion)),
                if (widget.inventario.fModificacion != null)
                  _buildInfoRow('Fecha Modificación',
                      AppUtils.formatDate(widget.inventario.fModificacion)),
                if (widget.inventario.usuarioIngreso != null &&
                    widget.inventario.usuarioIngreso!.isNotEmpty)
                  _buildInfoRow(
                      'Solicitado por', widget.inventario.usuarioIngreso!),
                if (widget.inventario.userModificacion != null &&
                    widget.inventario.userModificacion!.isNotEmpty)
                  _buildInfoRow('Usuario Modificación',
                      widget.inventario.userModificacion!),
                _buildInfoRow('ID Sucursal', '${widget.inventario.idSucursal}'),
                if (widget.inventario.idInventario != null)
                  _buildInfoRow(
                      'ID Inventario', '${widget.inventario.idInventario}'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: CustomButton(
                    text: 'Rechazar',
                    onPressed: widget.onRechazar,
                    colorButton: ThemeApp.error,
                    icon: Icons.cancel,
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: CustomButton(
                    text: 'Aceptar',
                    onPressed: widget.onAceptar,
                    colorButton: ThemeApp.success,
                    icon: Icons.save,
                  )),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 12,
                color: ThemeApp.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 12,
                color: ThemeApp.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventarioThumbnail extends StatelessWidget {
  const _InventarioThumbnail({required this.inventario});

  final InventarioEntity inventario;

  IconData _getIconFromCategoria() {
    if (inventario.categoria == null || inventario.categoria!.isEmpty) {
      return Icons.inventory_2_outlined;
    }

    try {
      if (ProductosCategorias.allCodes.contains(inventario.categoria)) {
        return ProductosCategorias.getIconFromCode(inventario.categoria!);
      }
    } catch (e) {
      // Si hay algún error, retornar el icono por defecto
    }
    return Icons.inventory_2_outlined;
  }

  Color _getColorFromCategoria() {
    if (inventario.categoria == null || inventario.categoria!.isEmpty) {
      return Colors.orange;
    }

    try {
      if (ProductosCategorias.allCodes.contains(inventario.categoria)) {
        return ProductosCategorias.getColorFromCode(inventario.categoria!);
      }
    } catch (e) {
      // Si hay algún error, retornar el color por defecto
    }
    return Colors.orange;
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
