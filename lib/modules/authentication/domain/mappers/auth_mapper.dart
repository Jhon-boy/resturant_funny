import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/sesion_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthMapper {
  static SesionEntity toSesionEntity(UserModel user) {
    const Uuid uuid =  Uuid();
    final token = uuid.v4();
    return SesionEntity(
      idUsuario: user.idUsuario!,
      token: token,
      fCreacion: AppUtils.getFechaActual(),
      fExpiracion: AppUtils.getFechaActual().add(const Duration(hours: 1)),
      activo: true,
    );
  }
}
