import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/user/domain/models/empleados_model.dart';
import 'package:resturant_funny/shared/widgets/dialog_generic_widget.dart';

class GestionarRolesDialog extends StatefulWidget {
  final EmpleadoModel empleado;
  final List<int> rolesActuales;
  final List<RolEntity> rolesDisponibles;
  final Function(RolEntity) onAgregarRol;
  final Function(RolEntity) onQuitarRol;

  const GestionarRolesDialog({
    super.key,
    required this.empleado,
    required this.rolesActuales,
    required this.rolesDisponibles,
    required this.onAgregarRol,
    required this.onQuitarRol,
  });

  @override
  State<GestionarRolesDialog> createState() => _GestionarRolesDialogState();
}

class _GestionarRolesDialogState extends State<GestionarRolesDialog> {
  @override
  Widget build(BuildContext context) {
    // Separar roles asignados de los disponibles
    final rolesAsignados = widget.rolesDisponibles
        .where((r) => widget.rolesActuales.contains(r.idRol))
        .toList();
    final rolesDisponiblesParaAgregar = widget.rolesDisponibles
        .where((r) => !widget.rolesActuales.contains(r.idRol))
        .toList();

    return DialogoPersonalizadoWidget(
      titulo: 'Gestionar Roles',
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del empleado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeApp.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: ThemeApp.primary,
                      child: Text(
                        widget.empleado.persona.nombres[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.empleado.persona.nombres} ${widget.empleado.persona.apellidos}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.empleado.usuario != null
                                ? 'Usuario: ${widget.empleado.usuario!.usuario ?? 'N/A'}'
                                : 'Sin usuario',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (rolesAsignados.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: ThemeApp.success,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Roles Asignados Actualmente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: ThemeApp.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...rolesAsignados
                    .map((rol) => _buildRolCard(context, rol, true)),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
              ],
              if (rolesDisponiblesParaAgregar.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: ThemeApp.primary,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Roles Disponibles para Agregar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: ThemeApp.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.rolesActuales.isEmpty
                      ? 'Seleccione los roles que desea asignar al empleado haciendo clic en "Agregar"'
                      : 'Puede agregar más roles haciendo clic en el botón "Agregar"',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                ...rolesDisponiblesParaAgregar
                    .map((rol) => _buildRolCard(context, rol, false)),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Todos los roles disponibles ya están asignados a este empleado',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRolCard(BuildContext context, RolEntity rol, bool tieneRol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: tieneRol ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: tieneRol ? ThemeApp.success : Colors.grey.shade300,
          width: tieneRol ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: tieneRol
                    ? ThemeApp.success.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                tieneRol ? Icons.check_circle : Icons.circle_outlined,
                color: tieneRol ? ThemeApp.success : Colors.grey.shade400,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),

            // Información del rol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rol.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: tieneRol ? ThemeApp.success : Colors.black87,
                    ),
                  ),
                  if (rol.codigo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Código: ${rol.codigo}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Botón de acción
            const SizedBox(width: 6),
            ElevatedButton.icon(
              onPressed: () async {
                if (tieneRol) {
                  // Para quitar, no cerrar el diálogo aquí - el callback lo manejará
                  await widget.onQuitarRol(rol);
                } else {
                  // Para agregar, cerrar el diálogo inmediatamente
                  widget.onAgregarRol(rol);
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(
                tieneRol
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                size: 14,
              ),
              label: Text(
                tieneRol ? 'Quitar' : 'Agregar',
                style: const TextStyle(fontSize: 11),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: tieneRol
                    ? ThemeApp.error.withOpacity(0.1)
                    : ThemeApp.success.withOpacity(0.1),
                foregroundColor: tieneRol ? ThemeApp.error : ThemeApp.success,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                minimumSize: const Size(0, 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
