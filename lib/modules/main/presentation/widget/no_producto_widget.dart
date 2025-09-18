import 'package:flutter/material.dart';

class NoProductosWidget extends StatelessWidget {
  const NoProductosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          "No hay productos disponibles en este momento.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
