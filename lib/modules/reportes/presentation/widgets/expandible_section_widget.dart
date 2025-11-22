import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

class ExpandibleSectionWidget extends StatefulWidget {
  final String titulo;
  final IconData icono;
  final Widget contenido;
  final Widget? contenidoInicial;
  final bool mostrarVerMas;

  const ExpandibleSectionWidget({
    super.key,
    required this.titulo,
    required this.icono,
    required this.contenido,
    this.contenidoInicial,
    this.mostrarVerMas = true,
  });

  @override
  State<ExpandibleSectionWidget> createState() =>
      _ExpandibleSectionWidgetState();
}

class _ExpandibleSectionWidgetState extends State<ExpandibleSectionWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tieneMasContenido = widget.contenidoInicial != null;
    final puedeExpandir = widget.mostrarVerMas && tieneMasContenido;

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: puedeExpandir
                ? () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(widget.icono, color: ThemeApp.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.textPrimary,
                    ),
                  ),
                ),
                if (puedeExpandir)
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: ThemeApp.primary,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedCrossFade(
            firstChild: widget.contenidoInicial ?? widget.contenido,
            secondChild: widget.contenido,
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
