import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/shared/baseApp/pantalla_base.dart';

class InventarioPage extends ConsumerStatefulWidget {
  const InventarioPage({super.key, required this.titulo});
  final String titulo;

  @override
  ConsumerState<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends ConsumerState<InventarioPage> {
  @override
  Widget build(BuildContext context) {
    return PantallaBase(
        onBack: () => Navigator.of(context).pop(),
        title: widget.titulo,
        body: body());
  }

  Widget body() {
    return const Center(
      child: Text('Inventario'),
    );
  }
}
