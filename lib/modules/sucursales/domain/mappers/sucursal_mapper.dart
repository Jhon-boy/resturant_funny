import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';

class MesaMapper {
  static Map<String, dynamic> updateMesaById(
      int numero, EstadosPersona estado) {
    return {
      'NUMERO': numero,
      'ESTADO': estado.state,
      'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
      'USERMODIFICACION': SingletonApp.getUser()?.idUsuario?.toString(),
    };
  }

  static MesaEntity toEntity(
      int idSucursal, int numero, EstadosPersona estado) {
    final usuario = SingletonApp.getUser();
    return MesaEntity(
      idMesa: null,
      idSucursal: idSucursal,
      numero: numero,
      estado: estado.state,
      fCreacion: AppUtils.getFechaActual(),
      usuarioIngreso: usuario?.idUsuario?.toString(),
    );
  }
}
