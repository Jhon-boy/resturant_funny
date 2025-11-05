import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/modules/user/data/datasource/rol_usuario_data_source.dart';
import 'package:resturant_funny/modules/user/domain/repository/rol_usuario.dart';
import 'package:resturant_funny/shared/enums/roles.dart';

class RolUsuarioRepositoryImpl implements RolUsuarioRepository {
  final RolUsuarioRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  RolUsuarioRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, List<TUsuariEntity>>> getUsuariosByRol(Rol rol) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final usuarios = await remote.getUsuariosByRol(rol.code);
      return Right(usuarios);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<TUsuariEntity>>>
      getUsuariosSinRolCliente() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final usuarios = await remote.getUsuariosSinRolCliente();
      return Right(usuarios);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  /// Quitar rol de un usuario
  @override
  Future<Either<Failure, bool>> quitarRolUsuario(int idUsuario, Rol rol) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final result = await remote.quitarRolUsuario(idUsuario, rol.code);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  /// Obtener roles de un usuario
  @override
  Future<Either<Failure, List<int>>> getRolesUsuario(int idUsuario) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final roles = await remote.getRolesUsuario(idUsuario);
      return Right(roles);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<RolEntity>>> getAllRoles() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final roles = await remote.getRoles();
      return Right(roles);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> agregarRolUsuarioById(
      int idUsuario, int idRol) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final result = await remote.agregarRolUsuario(idUsuario, idRol);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> quitarRolUsuarioById(
      int idUsuario, int idRol) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final result = await remote.quitarRolUsuarioByIdRol(idUsuario, idRol);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
