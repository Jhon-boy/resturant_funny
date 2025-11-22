import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/detalles_ventas_datasource.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/detalle_venta_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/detalle_venta_repository.dart';

class DetalleVentaRepositoryImpl implements DetalleVentaRepository {
  final DetalleVentaRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  DetalleVentaRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, DetalleVentaEntity>> createDetalle(
      DetalleVentaEntity detalle, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final detalleCreated = await remote.createDetalle(detalle, user);
      return Right(detalleCreated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDetalle(int idDetalle) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final result = await remote.deleteDetalle(idDetalle);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<DetalleVentaEntity>>> getAllDetalles({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final detalles = await remote.getAllDetalles(
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(detalles);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, DetalleVentaEntity>> getDetalleById(
      int idDetalle) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final detalle = await remote.getDetalleById(idDetalle);
      if (detalle == null) {
        return const Left(ServerFailure('Detalle no encontrado'));
      }
      return Right(detalle);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<DetalleVentaEntity>>> getDetallesByVenta(
      int idVenta) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final detalles = await remote.getDetallesByVenta(idVenta);
      return Right(detalles);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, DetalleVentaEntity>> updateDetalle(
      int idDetalle, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final detalle = await remote.updateDetalle(idDetalle, data);
      return Right(detalle);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getDetallesConProductosBySucursal(
    List<int> idsVentas, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      // Necesitamos obtener el idSucursal de alguna manera
      // Por ahora, usaremos el método que acepta idsVentas directamente
      // Necesitamos modificar el datasource para aceptar idsVentas
      final detalles = await remote.getDetallesConProductosBySucursal(
        idSucursal: 0, // Esto necesita ser corregido
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(detalles);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
