import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/sucursales/presentation/sucursal_detalle_page.dart';
import 'package:resturant_funny/modules/user/domain/models/empleados_model.dart';

class SucursalCardWidget extends StatelessWidget {
  final SucursalEntity sucursal;
  final List<MesaEntity> mesas;
  final List<EmpleadoModel> empleados;

  const SucursalCardWidget({
    super.key,
    required this.sucursal,
    required this.mesas,
    required this.empleados,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          SucursalDetallePage.navigate(
            context: context,
            sucursal: sucursal,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: sucursal.isActiva
                        ? ThemeApp.primary
                        : Colors.grey.shade400,
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sucursal.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (sucursal.direccion != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Dirección: ${sucursal.direccion!}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 19,
                    color: ThemeApp.textPrimary
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.table_restaurant,
                    label:
                        '${mesas.length} mesa${mesas.length != 1 ? 's' : ''}',
                    color: ThemeApp.primary,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.people,
                    label:
                        '${empleados.length} empleado${empleados.length != 1 ? 's' : ''}',
                    color: ThemeApp.success,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: sucursal.isActiva ? Icons.check_circle : Icons.cancel,
                    label: sucursal.isActiva ? 'Activa' : 'Inactiva',
                    color: sucursal.isActiva ? ThemeApp.success : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
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
