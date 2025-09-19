import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/inventario/data/datasource/ingreso_egreso_data_source.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/ingreso_egreso_entity.dart';
import 'package:resturant_funny/modules/inventario/domain/repository/ingreso_egreso_repository.dart';

class IngresoEgresoRepositoryImpl implements IngresoEgresoRepository {
  final IngresoEgresoRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  IngresoEgresoRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, List<IngresoEgresoEntity>>> getAllMovimientos({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final movimientos = await remote.getMovimientos(
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(movimientos);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, IngresoEgresoEntity>> getMovimientoById(
      int idMovimiento) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final movimiento = await remote.getMovimientoById(idMovimiento);
      if (movimiento == null) {
        return const Left(ServerFailure('Movimiento no encontrado'));
      }
      return Right(movimiento);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<IngresoEgresoEntity>>> getMovimientosBySucursal(
    int idSucursal, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final movimientos = await remote.getMovimientos(
        idSucursal: idSucursal,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(movimientos);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, IngresoEgresoEntity>> createMovimiento(
      IngresoEgresoEntity movimiento, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final creado = await remote.createMovimiento(movimiento, user);
      return Right(creado);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, IngresoEgresoEntity>> updateMovimiento(
      int idMovimiento, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final actualizado = await remote.updateMovimiento(idMovimiento, data);
      return Right(actualizado);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMovimiento(int idMovimiento) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final result = await remote.deleteMovimiento(idMovimiento);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<IngresoEgresoEntity>>> searchMovimientos({
    String? tipo,
    String? categoria,
    double? montoMin,
    double? montoMax,
    String? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final movimientos = await remote.searchMovimientos(
        tipo: tipo,
        categoria: categoria,
        montoMin: montoMin,
        montoMax: montoMax,
        estado: estado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(movimientos);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
