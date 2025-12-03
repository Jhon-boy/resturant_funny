import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/inventario/presentation/inventario_page.dart';
import 'package:resturant_funny/modules/inventario/presentation/menu_page.dart';
import 'package:resturant_funny/modules/main/presentation/inicio_page.dart';
import 'package:resturant_funny/modules/notification/notifications_list.dart';
import 'package:resturant_funny/modules/notification/providers/notification_provider.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_page.dart';
import 'package:resturant_funny/modules/reportes/presentation/reportes_sesion.dart';
import 'package:resturant_funny/modules/roles/presentation/roles_page.dart';
import 'package:resturant_funny/modules/sucursales/presentation/sucursales_page.dart';
import 'package:resturant_funny/modules/user/presentation/empleados_page.dart';
import 'package:resturant_funny/modules/user/presentation/perfil_page.dart';
import 'package:resturant_funny/modules/user/presentation/crear_persona_page.dart';
import 'package:resturant_funny/modules/ventas/presentation/pages/mi_dia_page.dart';
import 'package:resturant_funny/modules/ventas/presentation/ventas_page.dart';
import 'package:resturant_funny/shared/baseApp/app_drawer.dart';
import 'package:resturant_funny/shared/baseApp/app_bottom_nav.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _userRole;
  String? _sucursal;
  @override
  void initState() {
    super.initState();
    _userRole = SingletonApp.getRolPrincipal();
    _sucursal = SingletonApp.getSucursalNombre();
    debugPrint('Rol actual: $_userRole');
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios en el índice de navegación desde páginas secundarias
    final navigationIndex = ref.watch(navigationIndexProvider);
    final currentIndex = navigationIndex;

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
          backgroundColor: ThemeApp.inputBackground,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
          title: Text(
            AppConstants.APP_NAME,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final notificationState = ref.watch(notificationProvider);
                final unreadCount = notificationState.unreadCount;

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
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
          currentIndex: currentIndex,
          userRole: _userRole,
          sucursal: _sucursal,
          onMainMenuTap: (index) {
            ref.read(navigationIndexProvider.notifier).state = index;
            Navigator.of(context).maybePop();
          },
          onDrawerMenuTap: (index) {
            _handleDrawerMenuTap(index);
          },
        ),
        body: IndexedStack(
          index: currentIndex,
          children: [
            InicioPage(onSectionChange: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
            }),
            const VentaPage(),
            const MiDiaPage(),
            const PerfilPage(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: currentIndex,
          onTap: (index) =>
              ref.read(navigationIndexProvider.notifier).state = index,
          onDrawerOpen: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
    );
  }

  // Manejar menús del drawer según el índice
  void _handleDrawerMenuTap(int index) {
    // Cerrar el drawer primero para todos los casos
    Navigator.of(context).pop();

    // Manejar menús del drawer según el índice
    switch (index) {
      case 4: // Configuración
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CrearPersonaPage(
              titulo: 'Gestión de Clientes',
            ),
          ),
        );
        break;
      case 5: // empleados
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const EmpleadosPage(
              titulo: 'Gestión de Empleados',
            ),
          ),
        );
        break;
      case 6: // Sucursales
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const SucursalesPage(
              titulo: 'Gestión de Sucursales',
            ),
          ),
        );
      case 7: // Menú
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MenuPage(
              titulo: 'Gestión de Menú',
            ),
          ),
        );
        break;
      case 8: // Inventario
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const InventarioPage(
              titulo: 'Gestión de Inventario',
            ),
          ),
        );
        break;
      case 9: // Reportes
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ReportesPage(
              titulo: 'Gestión de Reportes',
            ),
          ),
        );
        break;
      case 10: // Roles
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const RolesPage(
              titulo: 'Gestión de Roles',
            ),
          ),
        );
        break;
      case 11: // Sesión
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ReportesSesionPage(
              title: 'Gestión de Sesión',
            ),
          ),
        );
    }
  }
}
