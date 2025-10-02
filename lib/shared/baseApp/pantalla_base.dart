import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/shared/baseApp/app_drawer.dart';
import 'package:resturant_funny/shared/baseApp/app_bottom_nav.dart';

class PantallaBase extends StatefulWidget {
  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final Widget? floatingActionButton;
  final Widget? actions;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Function(int)? onSectionChange; // Callback para cambiar sección
  final bool blockSystemBack; // Bloquear botón de retroceder del sistema
  final VoidCallback?
      onSystemBack; // Acción personalizada al presionar retroceder

  const PantallaBase({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.floatingActionButton,
    this.actions,
    this.backgroundColor,
    this.appBarColor,
    this.onSectionChange,
    this.blockSystemBack = false,
    this.onSystemBack,
  });

  @override
  State<PantallaBase> createState() => _PantallaBaseState();
}

class _PantallaBaseState extends State<PantallaBase> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget scaffold = Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.appBarColor ?? ThemeApp.primary,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: ThemeApp.baseText),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: ThemeApp.baseText,
            fontFamily: ThemeApp.fontFamily,
          ),
        ),
        actions: [
          if (widget.actions != null) widget.actions!,
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.notifications_none_rounded,
                color: ThemeApp.baseText),
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
        currentIndex: 0,
        userRole: null,
        onMainMenuTap: (index) {
          if (widget.onSectionChange != null) {
            widget.onSectionChange!(index);
            Navigator.of(context).pop();
          }
        },
        onDrawerMenuTap: (index) {
          Navigator.of(context).pop();
        },
      ),
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (widget.onSectionChange != null) {
            widget.onSectionChange!(index);
            Navigator.of(context).pop();
          }
        },
        onDrawerOpen: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );

    if (widget.blockSystemBack) {
      return WillPopScope(
        // Bloquear el botón de retroceder del sistema
        onWillPop: () async {
          if (widget.onSystemBack != null) {
            widget.onSystemBack!();
          } else {
            AppUtils.logout(context);
          }
          return false;
        },
        child: scaffold,
      );
    }
    // Muestra la pantalla base
    return scaffold;
  }
}
