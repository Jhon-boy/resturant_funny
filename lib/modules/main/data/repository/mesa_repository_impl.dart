import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/main/data/datasource/mesa_remote_data_source.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/mesa_repository.dart';

class MesaRepositoryImpl implements MesaRepository {
  final MesasRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();
  MesaRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, MesaEntity>> createMesa(
      MesaEntity mesa, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final mesaCreated = await remote.createMesa(mesa, user);
      return Right(mesaCreated);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMesa(
      String idMesa, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.deleteMesa(idMesa, user);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<MesaEntity>>> getAllMesas() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final mesas = await remote.searchMesas();
      return Right(mesas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, MesaEntity>> getMesaById(String idMesa) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final mesa = await remote.getMesaById(idMesa);
      if (mesa == null) {
        return const Left(ServerFailure('Mesa no encontrada'));
      }
      return Right(mesa);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<MesaEntity>>> getMesasBySucursal(
      int idSucursal) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final mesas = await remote.getMesas(idSucursal);
      return Right(mesas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<MesaEntity>>> getMesasDisponibles(
      {int? idSucursal}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final mesas = await remote.searchMesas(disponible: true);
      if (idSucursal != null) {
        final mesasFiltradas =
            mesas.where((mesa) => mesa.idSucursal == idSucursal).toList();
        return Right(mesasFiltradas);
      }
      return Right(mesas);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, MesaEntity>> toggleEstadoMesa(String idMesa,
      {required String nuevoEstado}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final disponible = nuevoEstado.toLowerCase() == 'disponible';
      final mesa = await remote.toggleDisponibilidad(idMesa, disponible);
      return Right(mesa);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, MesaEntity>> updateMesaById(
      String idMesa, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final mesa = await remote.updateMesaById(idMesa, data);
      return Right(mesa);
    } catch (e) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
