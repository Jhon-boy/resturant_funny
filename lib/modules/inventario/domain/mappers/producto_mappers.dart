import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';

class ProductoMappers {
  static Map<String, dynamic> toUpdateJson(
      String nombre,
      String descripcion,
      double precio,
      String? imagen,
      String categoria,
      bool disponible,
      int idSucursal,
      int usuarioModificacion,
      ) {
    return {
      'NOMBRE': nombre,
      'DESCRIPCION': descripcion,
      'PRECIO': precio,
      'CATEGORIA': categoria,
      'IMAGEN': imagen,
      'DISPONIBLE': disponible,
      'IDSUCURSAL': idSucursal,
      'ESTADO': EstadosPersona.ACTIVO.state,
      'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
      'USERMODIFICACION': usuarioModificacion,
    };
  }
}
