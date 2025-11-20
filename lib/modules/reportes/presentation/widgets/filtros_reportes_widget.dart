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
          Row(
            children: [
              Expanded(
                child: CalendarWidget(
                  title: 'Fecha Inicio',
                  hint: 'Seleccionar',
                  selectedDate: fechaInicio,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  initialDate:
                      DateTime.now().subtract(const Duration(days: 30)),
                  icon: Icons.calendar_today,
                  onDateSelected: (fecha) {
                    if (fecha == null) {
                      onFechasChanged(null, fechaHasta);
                      return;
                    }

                    // Si hay fecha hasta y la diferencia es mayor a 3 días, ajustar
                    DateTime? nuevaFechaHasta = fechaHasta;
                    if (fechaHasta != null) {
                      final diferencia = fechaHasta!.difference(fecha).inDays;
                      if (diferencia > 3) {
                        nuevaFechaHasta = fecha.add(const Duration(days: 3));
                        if (nuevaFechaHasta.isAfter(DateTime.now())) {
                          nuevaFechaHasta = DateTime.now();
                        }
                      }
                    }

                    onFechasChanged(fecha, nuevaFechaHasta);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CalendarWidget(
                  title: 'Fecha Hasta',
                  hint: 'Seleccionar',
                  selectedDate: fechaHasta,
                  firstDate: fechaInicio ??
                      DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: fechaInicio != null
                      ? (fechaInicio!
                              .add(const Duration(days: 3))
                              .isBefore(DateTime.now())
                          ? fechaInicio!.add(const Duration(days: 3))
                          : DateTime.now())
                      : DateTime.now(),
                  initialDate: fechaInicio != null
                      ? (fechaInicio!
                              .add(const Duration(days: 1))
                              .isBefore(DateTime.now())
                          ? fechaInicio!.add(const Duration(days: 1))
                          : DateTime.now())
                      : DateTime.now(),
                  icon: Icons.calendar_today,
                  onDateSelected: (fecha) {
                    if (fecha == null) {
                      onFechasChanged(fechaInicio, null);
                      return;
                    }

                    // Validar que no sea mayor a 3 días desde fecha inicio
                    if (fechaInicio != null) {
                      final diferencia = fecha.difference(fechaInicio!).inDays;
                      if (diferencia > 3) {
                        // Mostrar error o ajustar automáticamente
                        final fechaMaxima =
                            fechaInicio!.add(const Duration(days: 3));
                        if (fechaMaxima.isAfter(DateTime.now())) {
                          onFechasChanged(fechaInicio, DateTime.now());
                        } else {
                          onFechasChanged(fechaInicio, fechaMaxima);
                        }
                        return;
                      }
                    }

                    onFechasChanged(fechaInicio, fecha);
                  },
                ),
              ),
            ],
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
