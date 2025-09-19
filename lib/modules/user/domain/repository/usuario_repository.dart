import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';

abstract class UsuariosRepository {
  /// Obtener todos los usuarios de una sucursal
  Future<Either<Failure, List<TUsuariEntity>>> getUsuariosBySucursal(
    int idSucursal, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  /// Obtener usuario por ID
  Future<Either<Failure, TUsuariEntity>> getUsuarioById(int idUsuario);

  /// Obtener usuario por identificación de persona
  Future<Either<Failure, TUsuariEntity>> getUsuarioByIdentificacion(
      String identificacion);

  /// Crear un nuevo usuario
  Future<Either<Failure, TUsuariEntity>> createUsuario(
    TUsuariEntity usuario,
  );

  /// Actualizar usuario (sin tocar identificación ni password)
  Future<Either<Failure, TUsuariEntity>> updateUsuario(
    int idUsuario,
    Map<String, dynamic> data,
  );

  /// Cambiar contraseña de usuario
  Future<Either<Failure, bool>> changePassword(
    int idUsuario,
    String oldPassword,
    String newPassword,
  );

  /// Resetear contraseña (admin)
  Future<Either<Failure, bool>> resetPassword(
    int idUsuario,
    String newPassword,
  );

  /// Activar/Desactivar usuario
  Future<Either<Failure, TUsuariEntity>> toggleEstadoUsuario(
    int idUsuario, {
    bool activo = true,
  });
}
