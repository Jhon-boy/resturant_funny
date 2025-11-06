import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';

class UsuarioMapper {
  static TUsuariEntity fromFormData({
    required String identificacion,
    required String user,
    required String password,
    required bool isTemporal,
  }) {
    final usuario = SingletonApp.getUser();
    return TUsuariEntity(
      idUsuario: 0,
      idSucursal: usuario!.idSucursal!,
      identificacion: identificacion,
      usuario: user,
      password: AppUtils.generateSha256(password.trim()),
      temporal: isTemporal,
      fCreacion: AppUtils.getFechaActual(),
      usuarioIngreso: usuario.idUsuario?.toString(),
    );
  }
}
