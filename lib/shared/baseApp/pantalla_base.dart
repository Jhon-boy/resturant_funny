import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/main/presentation/main_page.dart';
import 'package:resturant_funny/modules/notification/notifications_list.dart';
import 'package:resturant_funny/modules/notification/providers/notification_provider.dart';
import 'package:resturant_funny/shared/baseApp/app_drawer.dart';
import 'package:resturant_funny/shared/baseApp/app_bottom_nav.dart';

class PantallaBase extends ConsumerStatefulWidget {
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
  ConsumerState<PantallaBase> createState() => _PantallaBaseState();
}

class _PantallaBaseState extends ConsumerState<PantallaBase> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? rol;
  @override
  void initState() {
    super.initState();
    rol = SingletonApp.getRolPrincipal();
    debugPrint('Rol: $rol');
  }

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
          Consumer(
            builder: (context, ref, child) {
              final notificationState = ref.watch(notificationProvider);
              final unreadCount = notificationState.unreadCount;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: ThemeApp.baseText,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsList(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
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
        userRole: rol,
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
          debugPrint(' IDE: index: $index');
          if (widget.onSectionChange != null) {
            // Si hay callback, usarlo (páginas que están dentro de MainPage)
            widget.onSectionChange!(index);
            debugPrint(' IDE: onSectionChange: ${widget.onSectionChange}');
            Navigator.of(context).pop();
          } else {
            ref.read(navigationIndexProvider.notifier).state = index;
            // Hacer pop hasta encontrar MainPage o llegar a la raíz
            // Buscar si MainPage está en la pila de navegación
            bool foundMainPage = false;
            Navigator.of(context).popUntil((route) {
              // Verificar si la ruta es MainPage por el nombre de la ruta
              if (route.settings.name == '/base') {
                foundMainPage = true;
                return true;
              }
              // Si es la primera ruta (raíz), parar
              if (route.isFirst) {
                return true;
              }
              // Continuar haciendo pop
              return false;
            });
            // Si no encontramos MainPage en la pila, navegar a él
            if (!foundMainPage) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const MainPage(),
                  settings: const RouteSettings(name: '/base'),
                ),
                (route) => false,
              );
            }
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
            debugPrint("Bloqueado el botón de retroceder del sistema");
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
