import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/models/menu_item.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/imagenes.dart';

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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ThemeApp.background,
                ThemeApp.background.withOpacity(0.96),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDrawerHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildSectionTitle('Principal'),
                    const SizedBox(height: 4),
                    _buildMainMenus(mainMenus),
                    if (drawerMenus.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Divider(height: 1),
                      const SizedBox(height: 6),
                      _buildSectionTitle('Gestión'),
                      const SizedBox(height: 4),
                      _buildDrawerMenus(drawerMenus),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: _buildLogoutButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: ThemeApp.cardColors,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeApp.textPrimary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(Imagenes.logoApp, width: 100, height: 100),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Menú principal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeApp.textPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                if (userRole != null)
                  Text(
                    'Rol: ${userRole!.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeApp.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  )
                else
                  Text(
                    'Usuario sin rol asignado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ThemeApp.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w600,
          color: ThemeApp.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMainMenus(List<MenuItem> mainMenus) {
    return Column(
      children: mainMenus.map((menu) {
        final isSelected = currentIndex == menu.index;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: isSelected
                ? ThemeApp.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onMainMenuTap(menu.index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? ThemeApp.primary.withOpacity(0.15)
                            : ThemeApp.cardColors,
                      ),
                      child: Icon(
                        menu.icon,
                        size: 18,
                        color: isSelected
                            ? ThemeApp.primary
                            : ThemeApp.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        menu.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? ThemeApp.primary
                              : ThemeApp.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDrawerMenus(List<MenuItem> drawerMenus) {
    if (drawerMenus.isEmpty) return const SizedBox.shrink();

    return Column(
      children: drawerMenus.map((menu) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onDrawerMenuTap(menu.index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThemeApp.cardColors,
                      ),
                      child: Icon(
                        menu.icon,
                        size: 17,
                        color: ThemeApp.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        menu.label,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ThemeApp.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          AppUtils.logout(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeApp.error.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  color: ThemeApp.error,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeApp.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
