import 'package:flutter/material.dart';

class MenuItem {
  final String label;
  final IconData icon;
  final int index;
  final bool isMainMenu;
  final String? route;
  final VoidCallback? onTap;
  final bool requiresRole;
  final List<String>? allowedRoles;

  const MenuItem({
    required this.label,
    required this.icon,
    required this.index,
    this.isMainMenu = false,
    this.route,
    this.onTap,
    this.requiresRole = false,
    this.allowedRoles,
  });

  // Menús principales (BottomNavigationBar)
  static const List<MenuItem> mainMenus = [
    MenuItem(
      label: 'Inicio',
      icon: Icons.home_outlined,
      index: 0,
      isMainMenu: true,
    ),
    MenuItem(
      label: 'Venta',
      icon: Icons.point_of_sale_outlined,
      index: 1,
      isMainMenu: true,
    ),
    MenuItem(
      label: 'Mi Día',
      icon: Icons.insights_outlined,
      index: 2,
      isMainMenu: true,
    ),
    MenuItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      index: 3,
      isMainMenu: true,
    ),
  ];

  // Menús del drawer (dependientes del rol)
  static const List<MenuItem> drawerMenus = [
    MenuItem(
      label: 'Configuración',
      icon: Icons.settings_outlined,
      index: 4,
      isMainMenu: false,
      requiresRole: true,
      allowedRoles: ['admin', 'manager'],
    ),
    MenuItem(
      label: 'Inventario',
      icon: Icons.inventory_outlined,
      index: 5,
      isMainMenu: false,
      requiresRole: true,
      allowedRoles: ['admin', 'manager', 'inventory'],
    ),
    MenuItem(
      label: 'Reportes',
      icon: Icons.analytics_outlined,
      index: 6,
      isMainMenu: false,
      requiresRole: true,
      allowedRoles: ['admin', 'manager'],
    ),
    MenuItem(
      label: 'Usuarios',
      icon: Icons.people_outlined,
      index: 7,
      isMainMenu: false,
      requiresRole: true,
      allowedRoles: ['admin'],
    ),
    MenuItem(
      label: 'Ayuda',
      icon: Icons.help_outline,
      index: 8,
      isMainMenu: false,
    ),
    MenuItem(
      label: 'Acerca de',
      icon: Icons.info_outline,
      index: 9,
      isMainMenu: false,
    ),
  ];

  // Obtener menús del drawer filtrados por rol
  static List<MenuItem> getDrawerMenusForRole(String? userRole) {
    if (userRole == null) {
      return drawerMenus.where((menu) => !menu.requiresRole).toList();
    }

    return drawerMenus.where((menu) {
      if (!menu.requiresRole) return true;
      return menu.allowedRoles?.contains(userRole) ?? false;
    }).toList();
  }

  // Obtener menús principales
  static List<MenuItem> getMainMenus() {
    return mainMenus;
  }
}
