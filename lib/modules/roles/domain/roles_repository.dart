import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';

abstract class RolesRepository {
  Future<Either<Failure, List<RolEntity>>> cargarRoles();

  Future<Either<Failure, RolEntity>> createRol(
      {required String nombre,
      required String codigo,
      required String estado});

  Future<Either<Failure, RolEntity>> updateRol(RolEntity rol,
      {required String nombre,
      required String codigo,
      required String estado});

  Future<Either<Failure, bool>> deleteRol(RolEntity rol);
}
