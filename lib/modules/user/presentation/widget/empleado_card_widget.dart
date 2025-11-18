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
  final VoidCallback? onViewStatistics;

  const EmpleadoCardWidget({
    super.key,
    required this.empleado,
    required this.roles,
    this.onEdit,
    this.onDelete,
    this.onChangeSucursal,
    this.onViewStatistics,
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
              color: ThemeApp.textPrimary,
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
                    const Icon(Icons.badge_outlined,
                        size: 14, color: ThemeApp.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      empleado.persona.identificacion,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeApp.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (empleado.usuario != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: ThemeApp.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Usuario: ${empleado.usuario!.usuario ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeApp.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: ThemeApp.primary),
                      SizedBox(width: 4),
                      Expanded(
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
                  Row(
                    children: [
                      const Icon(Icons.rule_sharp,
                          size: 14, color: ThemeApp.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: ThemeApp.textSecondary,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: "Roles: "),
                              TextSpan(
                                text: roles
                                    .where(
                                        (r) => empleado.roles.contains(r.idRol))
                                    .map((r) => r.nombre)
                                    .join(', '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: ThemeApp.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
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
                  const Divider(height: 1, color: ThemeApp.textSecondary),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.settings, size: 20, color: ThemeApp.primary),
                      SizedBox(width: 8),
                      Text('Acciones disponibles',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ThemeApp.primary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          const Icon(Icons.location_on,
                              size: 20, color: ThemeApp.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                              'Sucursal: ${empleado.usuario?.idSucursal.toString() ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 12, color: ThemeApp.textSecondary)),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            if (onChangeSucursal != null) {
                              onChangeSucursal!();
                            }
                          },
                          icon: const Icon(Icons.assistant_direction_sharp,
                              size: 30, color: ThemeApp.primary)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          SizedBox(width: 4),
                          Icon(Icons.bar_chart,
                              size: 20, color: ThemeApp.textSecondary),
                          SizedBox(width: 8),
                          Text('Ver Estadisticas',
                              style: TextStyle(
                                  fontSize: 12, color: ThemeApp.textSecondary)),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            if (onViewStatistics != null) {
                              onViewStatistics!();
                            }
                          },
                          icon: const Icon(Icons.bar_chart_rounded,
                              size: 30, color: ThemeApp.primary)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          const Icon(Icons.rule_outlined,
                              size: 20, color: ThemeApp.textSecondary),
                          const SizedBox(width: 8),
                          Text('Gestionar Roles (${empleado.roles.length})',
                              style: const TextStyle(
                                  fontSize: 12, color: ThemeApp.textSecondary)),
                        ],
                      ),
                      IconButton(
                          onPressed: () {
                            if (onEdit != null) {
                              onEdit!();
                            }
                          },
                          icon: const Icon(Icons.edit_square,
                              size: 30, color: ThemeApp.primary)),
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
                            colorButton: ThemeApp.textSecondary,
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
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeApp.textSecondary,
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
