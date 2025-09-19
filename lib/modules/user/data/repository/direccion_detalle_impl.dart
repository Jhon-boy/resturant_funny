import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/user/data/datasource/direccion_detalle_data_source.dart';
import 'package:resturant_funny/modules/user/domain/entity/direccion_cliente_entity.dart';
import 'package:resturant_funny/modules/user/domain/repository/direccion_detalle_repository.dart';

class DireccionClienteRepositoryImpl implements DireccionClienteRepository {
  final DireccionClienteRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  DireccionClienteRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, DireccionClienteEntity>> createDireccion(
      DireccionClienteEntity direccion, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final created = await remote.createDireccion(direccion, user);
      return Right(created);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDireccion(int idDireccion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.deleteDireccion(idDireccion);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<DireccionClienteEntity>>>
      getAllDirecciones() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final direcciones = await remote.getAllDirecciones();
      return Right(direcciones);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, DireccionClienteEntity>> getDireccionById(
      int idDireccion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final direccion = await remote.getDireccionById(idDireccion);
      if (direccion == null) {
        return const Left(ServerFailure('Dirección no encontrada'));
      }
      return Right(direccion);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<DireccionClienteEntity>>> getDireccionesByCliente(
      String identificacion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final direcciones = await remote.getDireccionesByCliente(identificacion);
      return Right(direcciones);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, DireccionClienteEntity>> toggleEstadoDireccion(
      int idDireccion,
      {bool activo = true}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final direccion =
          await remote.toggleEstadoDireccion(idDireccion, activo: activo);
      return Right(direccion);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, DireccionClienteEntity>> updateDireccion(
      int idDireccion, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final direccion = await remote.updateDireccion(idDireccion, data);
      return Right(direccion);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
