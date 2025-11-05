import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/ventas/presentation/widget/cart_item.dart';
import 'package:resturant_funny/shared/widgets/dialog_generic_widget.dart';

class PorcionesWidget extends ConsumerStatefulWidget {
  final List<ProductoEntity> porciones;
  const PorcionesWidget({
    super.key,
    required this.porciones,
    required this.onSelected,
  });
  final Function(Map<int, int>) onSelected;

  @override
  ConsumerState<PorcionesWidget> createState() => _PorcionesWidgetState();
}

class _PorcionesWidgetState extends ConsumerState<PorcionesWidget> {
  final Map<int, int> _porcionesSeleccionadas = {};

  void _incrementarCantidad(int index) {
    setState(() {
      final porcionId = widget.porciones[index].idProducto;
      if (porcionId != null) {
        _porcionesSeleccionadas[porcionId] =
            (_porcionesSeleccionadas[porcionId] ?? 0) + 1;
      }
    });
  }

  void _disminuirCantidad(int index) {
    setState(() {
      final porcionId = widget.porciones[index].idProducto;
      if (porcionId != null) {
        final cantidadActual = _porcionesSeleccionadas[porcionId] ?? 0;
        if (cantidadActual > 0) {
          _porcionesSeleccionadas[porcionId] = cantidadActual - 1;
          if (_porcionesSeleccionadas[porcionId] == 0) {
            _porcionesSeleccionadas.remove(porcionId);
          }
        }
      }
    });
  }

  int _getCantidad(int index) {
    final porcionId = widget.porciones[index].idProducto;
    if (porcionId == null) return 0;
    return _porcionesSeleccionadas[porcionId] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return DialogoPersonalizadoWidget(
      onCancelPressed: () {},
      onAceptarPressed: () {
        widget.onSelected(Map<int, int>.from(_porcionesSeleccionadas));
      },
      titulo: "Seleccione las porciones",
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget.porciones.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No hay porciones disponibles',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      ...List.generate(widget.porciones.length, (index) {
                        final porcion = widget.porciones[index];
                        final cantidad = _getCantidad(index);
                        final precioTotal = porcion.precio * cantidad;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: cantidad > 0
                                ? const BorderSide(
                                    color: ThemeApp.primary, width: 2)
                                : BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MiniImagen(producto: porcion),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        porcion.nombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        porcion.precioFormateado,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (cantidad > 0) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Total: \$${precioTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: ThemeApp.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Controles de cantidad
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          _disminuirCantidad(index),
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      color: cantidad > 0
                                          ? ThemeApp.textPrimary
                                          : Colors.grey,
                                      iconSize: 24,
                                    ),
                                    Container(
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$cantidad',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: cantidad > 0
                                              ? ThemeApp.primary
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _incrementarCantidad(index),
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      color: ThemeApp.primary,
                                      iconSize: 24,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      if (_porcionesSeleccionadas.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ThemeApp.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total de porciones seleccionadas:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_porcionesSeleccionadas.values.fold(0, (sum, cantidad) => sum + cantidad)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: ThemeApp.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
