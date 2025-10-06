import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/main/presentation/inicio_page.dart';
import 'package:resturant_funny/modules/ventas/presentation/mi_dia_page.dart';
import 'package:resturant_funny/modules/ventas/presentation/ventas_page.dart';
import 'package:resturant_funny/shared/baseApp/app_drawer.dart';
import 'package:resturant_funny/shared/baseApp/app_bottom_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _userRole;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (_scaffoldKey.currentState?.isDrawerOpen == true) {
            Navigator.of(context).pop();
            return;
          }
          debugPrint("Bloqueado el botón de retroceder del sistema");
          AppUtils.logout(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
          title: Text(
            'Restaurant Funny',
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
          currentIndex: _currentIndex,
          userRole: _userRole,
          onMainMenuTap: (index) {
            setState(() => _currentIndex = index);
            Navigator.of(context).maybePop();
          },
          onDrawerMenuTap: (index) {
            _handleDrawerMenuTap(index);
            Navigator.of(context).maybePop();
          },
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            InicioPage(onSectionChange: (index) {
              setState(() => _currentIndex = index);
            }),
            const VentaPage(),
            const MiDiaPage(),
            const Center(child: Text('Más opciones')),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          onDrawerOpen: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
    );
  }

  // Manejar menús del drawer según el índice
  void _handleDrawerMenuTap(int index) {
    // Manejar menús del drawer según el índice
    switch (index) {
      case 4: // Configuración
        //  Navegar a configuración
        break;
      case 5: // Inventario
        //  Navegar a inventario
        break;
      case 6: // Reportes
        //  Navegar a reportes
        break;
      case 7: // Usuarios
        //  Navegar a usuarios
        break;
      case 8: // Ayuda
        //  Mostrar ayuda
        break;
      case 9: // Acerca de
        //  Mostrar acerca de
        break;
    }
  }
}
