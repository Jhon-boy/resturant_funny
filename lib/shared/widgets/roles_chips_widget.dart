import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';

/// Widget reutilizable para mostrar roles como chips
class RolesChipsWidget extends StatelessWidget {
  final List<RolEntity> roles;
  final List<int>? selectedRoleIds;
  final Function(RolEntity)? onRoleTap;
  final bool showOnlySelected;
  final double spacing;
  final double runSpacing;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? labelStyle;

  const RolesChipsWidget({
    super.key,
    required this.roles,
    this.selectedRoleIds,
    this.onRoleTap,
    this.showOnlySelected = false,
    this.spacing = 4.0,
    this.runSpacing = 4.0,
    this.selectedColor,
    this.unselectedColor,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final rolesToShow = showOnlySelected
        ? roles
            .where((r) => selectedRoleIds?.contains(r.idRol) ?? false)
            .toList()
        : roles;

    if (rolesToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: rolesToShow.map((rol) {
        final isSelected = selectedRoleIds?.contains(rol.idRol) ?? false;
        return Chip(
          label: Text(
            rol.nombre,
            style: labelStyle ?? const TextStyle(fontSize: 10),
          ),
          backgroundColor: isSelected
              ? (selectedColor ?? ThemeApp.baseText.withOpacity(0.2))
              : (unselectedColor ?? Colors.grey.shade200),
          padding: EdgeInsets.zero,
          onDeleted: onRoleTap != null
              ? () {
                  onRoleTap!(rol);
                }
              : null,
          deleteIcon: onRoleTap != null
              ? Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  size: 16,
                  color: isSelected ? ThemeApp.success : Colors.grey.shade600,
                )
              : null,
          avatar: isSelected
              ? const Icon(Icons.check_circle,
                  size: 16, color: ThemeApp.success)
              : null,
        );
      }).toList(),
    );
  }
}
