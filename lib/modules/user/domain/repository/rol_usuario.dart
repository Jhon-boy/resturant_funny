import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/shared/enums/roles.dart';

abstract class RolUsuarioRepository {
  /// Obtener todos los roles de la aplicacion
  Future<Either<Failure, List<RolEntity>>> getAllRoles();

  /// Obtener usuarios por rol
  Future<Either<Failure, List<TUsuariEntity>>> getUsuariosByRol(
    Rol rol,
  );

  /// Obtener todos los usuarios que NO sean CLIENTE
  Future<Either<Failure, List<TUsuariEntity>>> getUsuariosSinRolCliente();

  /// Agregar rol a un usuario por IDROL
  Future<Either<Failure, bool>> agregarRolUsuarioById(
    int idUsuario,
    int idRol,
  );

  /// Quitar rol de un usuario
  Future<Either<Failure, bool>> quitarRolUsuario(
    int idUsuario,
    Rol rol,
  );

  /// Quitar rol de un usuario por IDROL
  Future<Either<Failure, bool>> quitarRolUsuarioById(
    int idUsuario,
    int idRol,
  );

  /// Obtener roles (IDs) de un usuario
  Future<Either<Failure, List<int>>> getRolesUsuario(
    int idUsuario,
  );
}
