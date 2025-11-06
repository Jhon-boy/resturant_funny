// Widget personalizado para mostrar empleado con roles
import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/user/domain/models/empleados_model.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/roles_chips_widget.dart';

class EmpleadoCardWidget extends StatelessWidget {
  final EmpleadoModel empleado;
  final List<RolEntity> roles;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onChangeSucursal;

  const EmpleadoCardWidget({
    super.key,
    required this.empleado,
    required this.roles,
    this.onEdit,
    this.onDelete,
    this.onChangeSucursal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              empleado.persona.nombres[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            '${empleado.persona.nombres} ${empleado.persona.apellidos}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.badge_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      empleado.persona.identificacion,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (empleado.usuario != null) ...[
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Usuario: ${empleado.usuario!.usuario ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: Colors.orange.shade600),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Esta persona no tiene un usuario ni roles asignados',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeApp.error,
                            fontStyle: FontStyle.italic,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (empleado.roles.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      // Buscar roles desde BD por IDs
                      final rolesEmpleado = roles
                          .where((r) => empleado.roles.contains(r.idRol))
                          .toList();
                      return RolesChipsWidget(
                        roles: rolesEmpleado,
                        selectedRoleIds: empleado.roles,
                        spacing: 2.0,
                        runSpacing: 2.0,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          children: [
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    icon: Icons.badge,
                    label: 'Tipo de Identificación',
                    value: empleado.persona.tipoIdentificacion ??
                        'No especificado',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Fecha de Nacimiento',
                    value:
                        AppUtils.formatDate(empleado.persona.fechaNacimiento),
                  ),
                  const SizedBox(height: 12),
                  if (empleado.persona.correo != null &&
                      empleado.persona.correo!.isNotEmpty) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.email,
                      label: 'Correo',
                      value: empleado.persona.correo!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (empleado.persona.telefono != null &&
                      empleado.persona.telefono!.isNotEmpty) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: empleado.persona.telefono!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (empleado.persona.estado != null) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.info,
                      label: 'Estado',
                      value: EstadosPersona.getLabelFromState(
                          empleado.persona.estado!),
                      valueColor: EstadosPersona.getColorFromState(
                          empleado.persona.estado!),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          Icon(Icons.location_on,
                              size: 20, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                              'Sucursal: ${empleado.usuario?.idSucursal.toString() ?? 'N/A'}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            if (onChangeSucursal != null) {
                              onChangeSucursal!();
                            }
                          },
                          icon: const Icon(Icons.assistant_direction_sharp,
                              size: 30, color: ThemeApp.error)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          Icon(Icons.bar_chart,
                              size: 20, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text('Ver Estadisticas',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.bar_chart_rounded,
                              size: 30, color: ThemeApp.error)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          Icon(Icons.rule_outlined,
                              size: 20, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text('Gestionar Roles (${empleado.roles.length})',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            if (onEdit != null) {
                              onEdit!();
                            }
                          },
                          icon: const Icon(Icons.edit_square,
                              size: 30, color: ThemeApp.error)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (empleado.usuario == null) ...[
                    const SizedBox(height: 8),
                    CustomButton(
                      text: 'Crear Usuario',
                      icon: Icons.person_add,
                      colorButton: ThemeApp.primary,
                      colorText: Colors.white,
                      onPressed: onEdit ?? () {},
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Desactivar',
                            colorButton: ThemeApp.error,
                            colorText: Colors.white,
                            icon: Icons.delete,
                            onPressed: () {
                              if (onDelete != null) {
                                onDelete!();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
