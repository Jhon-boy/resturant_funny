import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/models/menu_item.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onDrawerOpen;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onDrawerOpen,
  });

  @override
  Widget build(BuildContext context) {
    final mainMenus = MenuItem.getMainMenus();

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        onTap(i);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: ThemeApp.primary,
      unselectedItemColor: ThemeApp.textSecondary,
      backgroundColor: ThemeApp.inputBackground,
      items: mainMenus.map((menu) {
        return BottomNavigationBarItem(
          icon: Icon(menu.icon),
          label: menu.label,
        );
      }).toList(),
    );
  }
}
