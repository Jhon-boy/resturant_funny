import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/data/datasource/facturas_data_source.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/factura_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/repository/factura_repository.dart';

class FacturasRepositoryImpl implements FacturasRepository {
  final FacturasRemoteDataSource remote;
  final ConnectivityService _connectivityService = ConnectivityService();
  FacturasRepositoryImpl(this.remote) {
    _connectivityService.initialize();
  }

  @override
  Future<Either<Failure, FacturaEntity>> createFactura(
      FacturaEntity factura, UserModel user) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexion a internert'));
    }
    try {
      final create = await remote.createFactura(factura, user);
      return Right(create);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error. Intentalo mas tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFactura(int idFactura) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexion a internert'));
    }
    try {
      final delete = await remote.deleteFactura(idFactura);
      return Right(delete);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error. Intentalo mas tarde'));
    }
  }

  @override
  Future<Either<Failure, List<FacturaEntity>>> getAllFacturas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexion a internert'));
    }
    try {
      final list = await remote.getAllFacturas(
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
      return Right(list);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error. Intentalo mas tarde'));
    }
  }

  @override
  Future<Either<Failure, FacturaEntity>> getFacturaById(int idFactura) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexion a internert'));
    }
    try {
      final list = await remote.getFacturaById(idFactura);
      if (list != null) {
        return Right(list);
      } else {
        return Left(
            NotFoundFailure('No existe la factura con el ID: $idFactura'));
      }
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error. Intentalo mas tarde'));
    }
  }

  @override
  Future<Either<Failure, FacturaEntity>> getFacturaByNumero(
      String numeroFactura) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexion a internert'));
    }
    try {
      final factura = await remote.getFacturaByNumero(numeroFactura);
      if (factura != null) {
        return Right(factura);
      } else {
        return Left(NotFoundFailure(
            'No se encuentra la factura con el ID:  $numeroFactura'));
      }
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error. Intentalo mas tarde'));
    }
  }

  @override
  Future<Either<Failure, List<FacturaEntity>>> getFacturasByCliente(
      String idCliente) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexion a internert'));
    }
    try {
      final list = await remote.getFacturasByCliente(idCliente);
      return Right(list);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error. Intentalo mas tarde'));
    }
  }

  @override
  Future<Either<Failure, List<FacturaEntity>>> searchFacturas(
      {String? numeroFactura,
      String? idCliente,
      DateTime? fechaDesde,
      DateTime? fechaHasta,
      double? totalMin,
      double? totalMax}) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexion a internert'));
    }
    try {
      final list = await remote.searchFacturas(
        numeroFactura: numeroFactura,
        idCliente: idCliente,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        totalMin: totalMin,
        totalMax: totalMax,
      );
      return Right(list);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error. Intentalo mas tarde'));
    }
  }

  @override
  Future<Either<Failure, FacturaEntity>> updateFactura(
      int idFactura, Map<String, dynamic> data) async {
    final isConnected = await _connectivityService.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexion a internert'));
    }
    try {
      final updated = await remote.updateFactura(idFactura, data);
      return Right(updated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error. Intentalo mas tarde'));
    }
  }
}
