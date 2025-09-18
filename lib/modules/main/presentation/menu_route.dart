import 'package:flutter/material.dart';
import 'package:resturant_funny/modules/main/presentation/inicio_page.dart';
import 'package:resturant_funny/modules/main/presentation/pantalla_base.dart';
import 'package:resturant_funny/modules/ventas/presentation/ventas_page.dart';
import 'package:resturant_funny/modules/main/presentation/pantalla_items.dart';

class MenuRoute extends StatelessWidget {
  const MenuRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const PantallaBase(
      items: [
        PantallaBaseItem(
            label: 'Inicio', icon: Icons.home_outlined, builder: _inicio),
        PantallaBaseItem(
            label: 'Venta',
            icon: Icons.point_of_sale_outlined,
            builder: _venta),
        PantallaBaseItem(
            label: 'Mi Día', icon: Icons.insights_outlined, builder: _midia),
        PantallaBaseItem(
            label: 'Más', icon: Icons.menu_open_outlined, builder: _mas),
      ],
    );
  }

  static Widget _inicio(BuildContext context) => const InicioPage();
  static Widget _venta(BuildContext context) => const VentaPage();
  static Widget _midia(BuildContext context) => const MiDiaPage();
  static Widget _mas(BuildContext context) =>
      const Center(child: Text('Más opciones'));
}
