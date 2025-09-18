import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/presentation/pantalla_items.dart';

class PantallaBase extends StatefulWidget {
  const PantallaBase(
      {super.key, required this.items, this.title = 'Restaurant Funny'});

  final List<PantallaBaseItem> items;
  final String title;

  @override
  State<PantallaBase> createState() => _PantallaBaseState();
}

class _PantallaBaseState extends State<PantallaBase> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final current = widget.items[_currentIndex];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        leading: (Navigator.of(context).canPop() || _currentIndex != 0)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).maybePop();
                    return;
                  }
                  if (_currentIndex != 0) {
                    setState(() => _currentIndex = 0);
                  }
                },
              )
            : null,
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: ThemeApp.inputBorder,
          ),
        ),
      ),
      drawer: AppDrawer(
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
        onTap: (i) {
          final lastIndex = widget.items.length - 1;
          if (i == lastIndex) {
            _scaffoldKey.currentState?.openDrawer();
            return;
          }
          setState(() => _currentIndex = i);
        },
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
