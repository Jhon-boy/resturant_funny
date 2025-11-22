import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

class NotFoundCard extends StatelessWidget {
  const NotFoundCard({super.key, this.message, this.icon});
  final String? message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon ?? Icons.inventory_2_outlined,
            size: 64,
            color: ThemeApp.textPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'No se encontraron productos en el período seleccionado',
            style: const TextStyle(
              fontSize: 16,
              color: ThemeApp.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
