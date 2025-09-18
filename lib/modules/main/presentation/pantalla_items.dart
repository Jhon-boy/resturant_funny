import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class PantallaBaseItem {
  const PantallaBaseItem({
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

class AppDrawer extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const AppDrawer({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<PantallaBaseItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menú',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color.fromARGB(255, 26, 25, 25),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            for (int i = 0; i < items.length; i++)
              ListTile(
                leading: Icon(items[i].icon,
                    color: i == currentIndex ? ThemeApp.apple : null),
                title: Text(items[i].label),
                selected: i == currentIndex,
                onTap: () => onSelected(i),
              ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.of(context).maybePop();
                final navigator = AppUtils.navigatorKey.currentState;
                DialogHelper.confirm(
                  context,
                  message: '¿Estás seguro de querer cerrar sesión?',
                  onConfirm: () {
                    navigator?.pushNamedAndRemoveUntil(
                        '/login', (route) => false);
                  },
                  onCancel: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
