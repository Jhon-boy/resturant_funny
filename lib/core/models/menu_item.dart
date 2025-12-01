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
      requiresRole: false,
    ),
    MenuItem(
      label: 'Ordenar',
      icon: Icons.point_of_sale_outlined,
      index: 1,
      isMainMenu: true,
      requiresRole: false,
    ),
    MenuItem(
      label: 'Mi Día',
      icon: Icons.insights_outlined,
      index: 2,
      isMainMenu: true,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      index: 3,
      isMainMenu: true,
      requiresRole: false,
    ),
  ];

  // Menús del drawer (dependientes del rol)
  static const List<MenuItem> drawerMenus = [
    MenuItem(
      label: 'Clientes',
      icon: Icons.people_outline,
      index: 4,
      isMainMenu: true,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Empleados',
      icon: Icons.person_pin_outlined,
      index: 5,
      isMainMenu: true,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Sucursales',
      icon: Icons.inventory_outlined,
      index: 6,
      isMainMenu: true,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Ménu',
      icon: Icons.restaurant_menu_rounded,
      index: 7,
      isMainMenu: false,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Inventario',
      icon: Icons.production_quantity_limits,
      index: 8,
      isMainMenu: true,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Reportes',
      icon: Icons.data_exploration_outlined,
      index: 9,
      isMainMenu: true,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Roles',
      icon: Icons.security_outlined,
      index: 10,
      isMainMenu: false,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Sesiones',
      icon: Icons.phone_android_outlined,
      index: 11,
      isMainMenu: true,
      requiresRole: true,
      allowedRoles: ['ADM'],
    ),
    MenuItem(
      label: 'Acerca de',
      icon: Icons.info_outline,
      index: 12,
      isMainMenu: false,
      requiresRole: false,
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
