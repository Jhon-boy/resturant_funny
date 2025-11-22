import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/calendar_widget.dart';

class FiltrosReportesWidget extends StatelessWidget {
  final SucursalEntity? sucursalSeleccionada;
  final List<SucursalEntity> sucursales;
  final DateTime? fechaInicio;
  final DateTime? fechaHasta;
  final Function(SucursalEntity?) onSucursalChanged;
  final Function(DateTime?, DateTime?) onFechasChanged;
  final bool cargando;

  const FiltrosReportesWidget({
    super.key,
    required this.sucursalSeleccionada,
    required this.sucursales,
    required this.fechaInicio,
    required this.fechaHasta,
    required this.onSucursalChanged,
    required this.onFechasChanged,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeApp.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.store, color: ThemeApp.primary),
              SizedBox(width: 8),
              Text('Sucursal',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.textPrimary)),
            ],
          ),
          CustomDropdown<SucursalEntity>(
            value: sucursalSeleccionada,
            label: 'Sucursal',
            hint: 'Seleccione una sucursal',
            items: sucursales,
            displayText: (s) => s.nombre,
            onChanged: (s) => onSucursalChanged(s),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.calendar_today, color: ThemeApp.primary),
              SizedBox(width: 8),
              Text('Rango de Fechas (máx. 3 días)',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          DateRangeWidget(
            title: 'Rango de Fechas (máx. 3 días)',
            startDate: fechaInicio,
            endDate: fechaHasta,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now(),
            onDateRangeSelected: (desde, hasta) {
              if (desde != null && hasta != null) {
                final diferencia = hasta.difference(desde).inDays;
                if (diferencia > 3) {
                  final nuevaFechaHasta = desde.add(const Duration(days: 3));
                  if (nuevaFechaHasta.isAfter(DateTime.now())) {
                    onFechasChanged(desde, DateTime.now());
                  } else {
                    onFechasChanged(desde, nuevaFechaHasta);
                  }
                } else {
                  onFechasChanged(desde, hasta);
                }
              } else {
                onFechasChanged(desde, hasta);
              }
            },
          ),
          if (fechaInicio != null && fechaHasta != null)
            Builder(
              builder: (context) {
                final diferencia = fechaHasta!.difference(fechaInicio!).inDays;
                if (diferencia == 3) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: ThemeApp.primary),
                        SizedBox(width: 4),
                        Text(
                          'Rango de 3 días - Comparativa disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeApp.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }
}
