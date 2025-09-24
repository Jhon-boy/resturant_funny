import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/modules/user/data/datasource/usuario_data_source.dart';
import 'package:resturant_funny/modules/user/domain/repository/usuario_repository.dart';

class UsuariosRepositoryImpl implements UsuariosRepository {
  final UsuariosRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  UsuariosRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, List<TUsuariEntity>>> getUsuariosBySucursal(
    int idSucursal, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final usuarios = await remote.getUsuariosBySucursal(
        idSucursal,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(usuarios);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TUsuariEntity>> getUsuarioById(int idUsuario) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final usuario = await remote.getUsuarioById(idUsuario);
      if (usuario == null) {
        return const Left(ServerFailure('Usuario no encontrado'));
      }
      return Right(usuario);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TUsuariEntity>> getUsuarioByIdentificacion(
      String identificacion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final usuario = await remote.getUsuarioByIdentificacion(identificacion);
      if (usuario == null) {
        return const Left(ServerFailure('Usuario no encontrado'));
      }
      return Right(usuario);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TUsuariEntity>> createUsuario(
      TUsuariEntity usuario) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final created = await remote.createUsuario(usuario);
      return Right(created);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TUsuariEntity>> updateUsuario(
      int idUsuario, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final updated = await remote.updateUsuario(idUsuario, data);
      return Right(updated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(
      int idUsuario, String oldPassword, String newPassword) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final result =
          await remote.changePassword(idUsuario, oldPassword, newPassword);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
      int idUsuario, String newPassword) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final result = await remote.resetPassword(idUsuario, newPassword);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TUsuariEntity>> toggleEstadoUsuario(int idUsuario,
      {bool activo = true}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final updated =
          await remote.toggleEstadoUsuario(idUsuario, activo: activo);
      return Right(updated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
