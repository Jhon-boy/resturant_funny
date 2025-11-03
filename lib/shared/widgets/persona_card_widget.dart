import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';

class PersonaCardWidget extends StatelessWidget {
  final PersonaEntity persona;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PersonaCardWidget({
    super.key,
    required this.persona,
    this.onEdit,
    this.onDelete,
  });

  IconData _getIconoGenero() {
    final genero = persona.genero?.toUpperCase() ?? '';
    if (genero.contains('FEMENINO') || genero == 'F') {
      return Icons.woman;
    } else if (genero.contains('MASCULINO') || genero == 'M') {
      return Icons.man;
    }
    return Icons.person;
  }

  Color _getColorGenero() {
    final genero = persona.genero?.toUpperCase() ?? '';
    if (genero.contains('FEMENINO') || genero == 'F') {
      return Colors.pink.shade300;
    } else if (genero.contains('MASCULINO') || genero == 'M') {
      return Colors.blue.shade300;
    }
    return Colors.grey.shade400;
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'No especificada';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

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
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getColorGenero().withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconoGenero(),
              color: _getColorGenero(),
              size: 32,
            ),
          ),
          title: Text(
            '${persona.nombres} ${persona.apellidos}',
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
            child: Row(
              children: [
                Icon(Icons.badge_outlined,
                    size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  persona.identificacion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
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
                  // Información detallada
                  _buildInfoRow(
                    context,
                    icon: Icons.badge,
                    label: 'Tipo de Identificación',
                    value: persona.tipoIdentificacion ?? 'No especificado',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Fecha de Nacimiento',
                    value: _formatearFecha(persona.fechaNacimiento),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    icon: _getIconoGenero(),
                    label: 'Género',
                    value:  AppUtils.mapearGeneroDesdeBD(persona.genero) ?? 'No especificado',
                  ),
                  const SizedBox(height: 12),
                  if (persona.correo != null && persona.correo!.isNotEmpty) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.email,
                      label: 'Correo',
                      value: persona.correo!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (persona.telefono != null &&
                      persona.telefono!.isNotEmpty) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.phone,
                      label: 'Teléfono',
                      value: persona.telefono!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (persona.direccion != null &&
                      persona.direccion!.isNotEmpty) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on,
                      label: 'Dirección',
                      value: persona.direccion!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (persona.estado != null) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.info,
                      label: 'Estado',
                      value: EstadosPersona.getLabelFromState(persona.estado!),
                      valueColor:
                          EstadosPersona.getColorFromState(persona.estado!),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (persona.estado != null) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.date_range,
                      label: 'F. Creación',
                      value: AppUtils.formatDate(persona.fCreacion),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (persona.estado != null) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.date_range,
                      label: 'F. Modificación',
                      value: AppUtils.formatDate(persona.fModificacion),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Editar',
                          colorButton: ThemeApp.primary,
                          colorText: Colors.white,
                          icon: Icons.edit,
                          onPressed: () {
                            if (onEdit != null) {
                              onEdit!();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Eliminar',
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
