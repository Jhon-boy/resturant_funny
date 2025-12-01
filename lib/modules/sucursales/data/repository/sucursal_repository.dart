import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';

class SucursalRemoteRepository implements SucursalRepository {
  final SucursalRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  SucursalRemoteRepository(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, bool>> deleteSucursalEntity(
      int idSucursal, String userModificacion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final sucursales =
          await remote.deleteSucursal(idSucursal, userModificacion);
      return Right(sucursales);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, SucursalEntity>> registerSucursalEntity(
      SucursalEntity data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final sucursales = await remote.createSucursal(data);
      return Right(sucursales);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<SucursalEntity>>> getSucursalesEntity() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final sucursales = await remote.getSucursales();
      return Right(sucursales);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, SucursalEntity>> getSucursalesbyIdEntity(
      int idSucursal) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final sucursales = await remote.getSucursalById(idSucursal);
      if (sucursales != null) {
        return Right(sucursales);
      } else {
        return Left(NotFoundFailure(
            "No se encontro la sucursal con el ID: $idSucursal"));
      }
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, SucursalEntity>> updateSucursalEntity(
      SucursalEntity data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final sucursales = await remote.updateSucursal(data);
      return Right(sucursales);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<SucursalEntity>>>
      getSucursalesEntityFree() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final sucursales = await remote.getSucursalesFree();
      return Right(sucursales);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
