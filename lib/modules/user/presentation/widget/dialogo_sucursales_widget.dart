import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/shared/widgets/custom_dropdown.dart';
import 'package:resturant_funny/shared/widgets/dialog_generic_widget.dart';

class GestionarSucursalesDialog extends StatefulWidget {
  final int? idSucursalActual;
  final List<SucursalEntity> sucursales;
  final Function(SucursalEntity) onSucursalSeleccionada;
  final String? titulo;
  final String? nombrePersona;

  const GestionarSucursalesDialog({
    super.key,
    this.idSucursalActual,
    required this.sucursales,
    required this.onSucursalSeleccionada,
    this.titulo,
    this.nombrePersona,
  });

  @override
  State<GestionarSucursalesDialog> createState() =>
      _GestionarSucursalesDialogState();
}

class _GestionarSucursalesDialogState extends State<GestionarSucursalesDialog> {
  SucursalEntity? _sucursalSeleccionada;

  @override
  void initState() {
    super.initState();
    if (widget.idSucursalActual != null) {
      _sucursalSeleccionada = widget.sucursales.firstWhere(
        (s) => s.idSucursal == widget.idSucursalActual,
        orElse: () => widget.sucursales.isNotEmpty
            ? widget.sucursales.first
            : widget.sucursales.first,
      );
    } else if (widget.sucursales.isNotEmpty) {
      _sucursalSeleccionada = widget.sucursales.first;
    }
  }

  SucursalEntity? get _sucursalActual {
    if (widget.idSucursalActual == null) return null;
    try {
      return widget.sucursales.firstWhere(
        (s) => s.idSucursal == widget.idSucursalActual,
      );
    } catch (e) {
      return null;
    }
  }

  bool get _puedeCambiar {
    if (_sucursalSeleccionada == null) return false;
    if (_sucursalActual == null) return true;
    return _sucursalSeleccionada!.idSucursal != _sucursalActual!.idSucursal;
  }

  @override
  Widget build(BuildContext context) {
    return DialogoPersonalizadoWidget(
      titulo: widget.titulo ?? 'Sucursal',
      buttonTitle: 'Seleccionar',
      onAceptarPressed: _puedeCambiar
          ? () {
              if (_sucursalSeleccionada != null) {
                widget.onSucursalSeleccionada(_sucursalSeleccionada!);
                Navigator.of(context).pop();
              }
            }
          : null,
      blockButton: !_puedeCambiar,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información de sucursal actual (solo si hay nombre de persona)
              if (widget.nombrePersona != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeApp.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: ThemeApp.primary,
                        child: Text(
                          widget.nombrePersona![0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nombrePersona!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (_sucursalActual != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.store,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Sucursal actual: ${_sucursalActual!.nombre}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (widget.idSucursalActual == null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 12,
                                    color: Colors.orange.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'No tiene sucursal asignada',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (widget.sucursales.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No hay sucursales disponibles',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Row(
                  children: [
                    Icon(
                      Icons.store,
                      color: ThemeApp.primary,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Seleccione una Sucursal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: ThemeApp.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomDropdown<SucursalEntity>(
                  value: _sucursalSeleccionada,
                  label: 'Sucursal',
                  hint: 'Seleccione una sucursal',
                  items: widget.sucursales,
                  displayText: (sucursal) => sucursal.nombre,
                  onChanged: (sucursal) {
                    setState(() {
                      _sucursalSeleccionada = sucursal;
                    });
                  },
                  enabled: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
