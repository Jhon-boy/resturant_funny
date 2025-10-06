import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/ventas_data_source.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/venta_repository.dart';

class VentaRepositoryImpl implements VentaRepository {
  final VentasRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  VentaRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, VentaEntity>> createVenta(
      VentaEntity venta, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final created = await remote.createVenta(venta, user);
      return Right(created);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, VentaEntity>> getVentaById(int idVenta) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final venta = await remote.getVentaById(idVenta);
      if (venta == null) {
        return const Left(NotFoundFailure('Venta no encontrada'));
      }
      return Right(venta);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaEntity>>> getVentas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final ventas = await remote.getAllVentas(
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(ventas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaEntity>>> getVentasBySucursal(
      int idSucursal) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final ventas = await remote.getVentasBySucursal(idSucursal);
      return Right(ventas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaEntity>>> getVentasByUsuario(
      String identificacion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final ventas = await remote.getVentasByUsuario(identificacion);
      return Right(ventas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, VentaEntity>> updateVenta(
      int idVenta, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final updated = await remote.updateVenta(idVenta, data);
      return Right(updated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, VentaEntity>> toggleEstadoVenta(int idVenta,
      {required String nuevoEstado}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final venta = await remote.toggleEstadoVenta(idVenta, nuevoEstado);
      return Right(venta);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<VentaEntity>>> getVentasBy(int idEmpleado,
      {DateTime? fechaDesde, DateTime? fechaHasta}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final ventas = await remote.getVentasBy(
        idEmpleado,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(ventas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
