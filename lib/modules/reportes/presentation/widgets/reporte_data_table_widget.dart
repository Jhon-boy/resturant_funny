import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';

/// Widget genérico para mostrar tablas de datos en los reportes
/// Mantiene un estilo consistente en toda la aplicación
class ReporteDataTableWidget extends StatelessWidget {
  /// Título de la tabla (opcional)
  final String? titulo;

  /// Icono para el título (opcional)
  final IconData? icono;

  /// Columnas de la tabla
  final List<DataColumn> columns;

  /// Filas de la tabla
  final List<DataRow> rows;

  /// Mensaje a mostrar cuando no hay datos
  final String? mensajeVacio;

  /// Si es true, muestra el título y el divider
  final bool mostrarTitulo;

  const ReporteDataTableWidget({
    super.key,
    this.titulo,
    this.icono,
    required this.columns,
    required this.rows,
    this.mensajeVacio,
    this.mostrarTitulo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (mostrarTitulo && titulo != null) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (icono != null) ...[
                    Icon(icono, color: ThemeApp.primary, size: 24),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    titulo!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          if (rows.isEmpty && mensajeVacio != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: ThemeApp.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mensajeVacio!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: ThemeApp.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  ThemeApp.primary.withOpacity(0.1),
                ),
                columns: columns,
                rows: rows,
              ),
            ),
        ],
      ),
    );
  }
}
