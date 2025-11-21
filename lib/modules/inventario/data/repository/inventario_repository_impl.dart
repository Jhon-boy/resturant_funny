import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/inventario/data/datasource/inventario_data_source.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/modules/inventario/domain/repository/inventario_repository.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';

class InventarioRepositoryImpl implements InventarioRepository {
  final InventarioRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  InventarioRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, InventarioEntity>> createInventario(
      InventarioEntity inventario, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final created = await remote.createInventario(inventario, user);
      return Right(created);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteInventario(int idInventario) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final deleted = await remote.deleteInventario(idInventario);
      return Right(deleted);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<InventarioEntity>>> getAllInventario() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final inventarios = await remote.getAllInventario();
      return Right(inventarios);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, InventarioEntity>> getInventarioById(
      int idInventario) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final inventario = await remote.getInventarioById(idInventario);
      if (inventario == null) {
        return const Left(ServerFailure('Inventario no encontrado'));
      }
      return Right(inventario);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<InventarioEntity>>> getInventarioBySucursal(
      int idSucursal) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final inventarios = await remote.getInventarioBySucursal(idSucursal);
      return Right(inventarios);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<InventarioEntity>>> searchInventario({
    String? nombre,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? stockMin,
    int? stockMax,
    String? estado,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final inventarios = await remote.searchInventario(
        nombre: nombre,
        categoria: categoria,
        precioMin: precioMin,
        precioMax: precioMax,
        stockMin: stockMin,
        stockMax: stockMax,
        estado: estado,
      );
      return Right(inventarios);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, InventarioEntity>> updateInventario(
      int idInventario, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final updated = await remote.updateInventario(idInventario, data);
      return Right(updated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<InventarioEntity>>>
      getInventarioBySucursalPending(int idSucursal) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final inventarios =
          await remote.getInventarioBySucursalPending(idSucursal);
      return Right(inventarios);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, InventarioEntity>> aceptarInventario(
      int idInventario) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final updated = await remote.updateInventario(idInventario, {
        'ESTADO': EstadosPersona.ACTIVO.getState,
        'FMODIFICACION': DateTime.now().toIso8601String(),
      });
      return Right(updated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, InventarioEntity>> rechazarInventario(
      int idInventario) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final updated = await remote.updateInventario(idInventario, {
        'ESTADO': EstadosPersona.INACTIVO.getState,
        'FMODIFICACION': DateTime.now().toIso8601String(),
      });
      return Right(updated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
