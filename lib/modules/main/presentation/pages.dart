import 'package:flutter/material.dart';

class VentaPage extends StatelessWidget {
  const VentaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Venta de productos',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class MiDiaPage extends StatelessWidget {
  const MiDiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Estadísticas del día',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
