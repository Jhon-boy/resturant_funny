import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/models/menu_item.dart'; 
import 'package:resturant_funny/core/utils/app_util.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onMainMenuTap;
  final Function(int) onDrawerMenuTap;
  final String? userRole;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onMainMenuTap,
    required this.onDrawerMenuTap,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final mainMenus = MenuItem.getMainMenus();
    final drawerMenus = MenuItem.getDrawerMenusForRole(userRole);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDrawerHeader(context),
            _buildMainMenus(mainMenus),
            _buildDrawerMenus(drawerMenus),
            const Spacer(),
            const Divider(height: 1),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Menú',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color.fromARGB(255, 26, 25, 25),
                  fontWeight: FontWeight.bold),
            ),
            if (userRole != null) ...[
              const SizedBox(height: 4),
              Text(
                'Rol: ${userRole!.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ThemeApp.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenus(List<MenuItem> mainMenus) {
    return Column(
      children: mainMenus.map((menu) {
        final isSelected = currentIndex == menu.index;
        return ListTile(
          leading: Icon(
            menu.icon,
            color: isSelected ? ThemeApp.primary : null,
          ),
          title: Text(menu.label),
          selected: isSelected,
          onTap: () => onMainMenuTap(menu.index),
        );
      }).toList(),
    );
  }

  Widget _buildDrawerMenus(List<MenuItem> drawerMenus) {
    if (drawerMenus.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Opciones',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ),
        ...drawerMenus.map((menu) {
          return ListTile(
            leading: Icon(menu.icon),
            title: Text(menu.label),
            onTap: () => onDrawerMenuTap(menu.index),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout_outlined),
      title: const Text('Cerrar Sesión'),
      onTap: () {
        AppUtils.logout(context);
      },
    );
  }
}
