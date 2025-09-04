import 'package:flutter/material.dart';
import 'package:resturant_funny/modules/main/presentation/base_shell.dart';
import 'package:resturant_funny/modules/main/presentation/pages.dart';

class BaseRoute extends StatelessWidget {
  const BaseRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseShell(
      items: [
        BaseShellItem(
            label: 'Inicio', icon: Icons.home_outlined, builder: _inicio),
        BaseShellItem(
            label: 'Venta',
            icon: Icons.point_of_sale_outlined,
            builder: _venta),
        BaseShellItem(
            label: 'Mi Día', icon: Icons.insights_outlined, builder: _midia),
        BaseShellItem(
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
