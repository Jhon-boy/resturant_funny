import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

class BaseShell extends StatefulWidget {
  const BaseShell(
      {super.key, required this.items, this.title = 'Restaurant Funny'});

  final List<BaseShellItem> items;
  final String title;

  @override
  State<BaseShell> createState() => _BaseShellState();
}

class _BaseShellState extends State<BaseShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final current = widget.items[_currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
        ),
        backgroundColor: ThemeApp.headerBackground,
        elevation: 2,
      ),
      drawer: _AppDrawer(
        items: widget.items,
        currentIndex: _currentIndex,
        onSelected: (i) {
          setState(() => _currentIndex = i);
          Navigator.of(context).maybePop();
        },
      ),
      body: current.builder(context),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: ThemeApp.primary,
        unselectedItemColor: ThemeApp.textSecondary,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        items: [
          for (final item in widget.items)
            BottomNavigationBarItem(icon: Icon(item.icon), label: item.label),
        ],
      ),
    );
  }
}

class BaseShellItem {
  const BaseShellItem({
    required this.label,
    required this.icon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<BaseShellItem> items;
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D0C22), Color(0xFF1A1A40)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menú',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configuración'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
