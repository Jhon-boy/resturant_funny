import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

class EstadisticaCardWidget extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;
  final Color color;
  final String? subtitulo;
  final VoidCallback? onTap;
  final bool showArrow;

  const EstadisticaCardWidget({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.color,
    this.subtitulo,
    this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeApp.baseText,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeApp.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitulo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitulo!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeApp.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showArrow && onTap != null) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: ThemeApp.textSecondary,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
