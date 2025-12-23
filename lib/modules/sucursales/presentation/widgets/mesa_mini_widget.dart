import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/crear_mesa_dialog.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';

class MesaMiniWidget extends StatelessWidget {
  final MesaEntity mesa;
  final Function(MesaEntity)? onMesaUpdated;
  final Function(MesaEntity)? onMesaDeleted;

  const MesaMiniWidget({
    super.key,
    required this.mesa,
    this.onMesaUpdated,
    this.onMesaDeleted,
  });

  Color _getEstadoColor() {
    if (mesa.estado == null) {
      return ThemeApp.success;
    }
    try { 
      final estadoNormalizado = EstadosPersona.allStates.firstWhere(
        (e) => e.toUpperCase() == mesa.estado!.toUpperCase(),
        orElse: () => EstadosPersona.ACTIVO.state,
      );
      return EstadosPersona.getColorFromState(estadoNormalizado);
    } catch (e) {
      return ThemeApp.success;
    }
  }

  String _getEstadoLabel() {
    if (mesa.estado == null) {
      return EstadosPersona.ACTIVO.label;
    }
    try { 
      final estadoNormalizado = EstadosPersona.allStates.firstWhere(
        (e) => e.toUpperCase() == mesa.estado!.toUpperCase(),
        orElse: () => EstadosPersona.ACTIVO.state,
      );
      return EstadosPersona.getLabelFromState(estadoNormalizado);
    } catch (e) {
      return mesa.estado ?? EstadosPersona.ACTIVO.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mesa ${mesa.numero ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Estado: '),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getEstadoColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getEstadoLabel(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(
                  //   width: 10,
                  // ),
                  // Row(
                  //   children: [
                  //     const Text('Sillas: '),
                  //     const SizedBox(width: 4),
                  //     Text(mesa.numero.toString()),
                  //   ],
                  // )
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                    onPressed: () async {
                      if (mesa.idSucursal != null) {
                        final mesaActualizada = await CrearMesaDialog.show(
                          context: context,
                          isEdit: true,
                          mesa: mesa,
                          idSucursal: mesa.idSucursal!,
                        );
                        if (mesaActualizada != null && onMesaUpdated != null) {
                          onMesaUpdated!(mesaActualizada);
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: ThemeApp.success,
                    )),
                IconButton(
                    onPressed: () {
                      onMesaDeleted!(mesa);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: ThemeApp.error,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
