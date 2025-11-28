import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/roles/data/datasource/roles_remote_datasource.dart';
import 'package:resturant_funny/modules/roles/domain/roles_repository.dart';

class RolesRepositoryImpl implements RolesRepository {
  final RolesRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  RolesRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, List<RolEntity>>> cargarRoles() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final roles = await remote.cargarRoles();
      return Right(roles);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, RolEntity>> createRol({
    required String estado,
    required String nombre,
    required String codigo,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final roles = await remote.createRol(
        nombre: nombre,
        codigo: codigo,
        estado: estado,
      );
      return Right(roles);
    } catch (_) {
      return const Left(
        ServerFailure('Ha ocurrido un error, inténtalo más tarde'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRol(RolEntity rol) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final isDelete = await remote.deleteRol(rol);
      return Right(isDelete);
    } catch (_) {
      return const Left(
        ServerFailure('Ha ocurrido un error, inténtalo más tarde'),
      );
    }
  }

  @override
  Future<Either<Failure, RolEntity>> updateRol(RolEntity rol,
      {required String nombre,
      required String codigo,
      required String estado}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final rolUpdate = await remote.updateRol(rol,
          nombre: nombre, codigo: codigo, estado: estado);
      return Right(rolUpdate);
    } catch (_) {
      return const Left(
        ServerFailure('Ha ocurrido un error, inténtalo más tarde'),
      );
    }
  }
}
