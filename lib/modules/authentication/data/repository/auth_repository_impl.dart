// ignore_for_file: unrelated_type_equality_checks

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/models/deviceInfo_model.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/dispositivo_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/authentication/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSourceImpl remoteDataSource;
  final ConnectivityService _connectivity = ConnectivityService();

  AuthRepositoryImpl({
    required this.remoteDataSource,
  }) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, UserModel>> login(
      String email, String password) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, intentalo mas luego'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> checkAuthStatus() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final user = await remoteDataSource.checkAuthStatus();
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error in checkAuthStatus'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS: $e');
      return const Left(ServerFailure('Unexpected error in logout'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> isTrustedDevice(
      DeviceInfoModel deviceInfo) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      // ignore: non_constant_identifier_names
      final UserModel = await remoteDataSource.isTrustedDevice(deviceInfo);
      if (UserModel == null) {
        return const Left(DatabaseFailure('Dispositivo no autorizado'));
      }
      return Right(UserModel);
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS: $e');
      return const Left(DatabaseFailure('Error verificando dispositivo'));
    }
  }

  /// Verifica si el dispositivo actual es de confianza (método conveniente)
  Future<Either<Failure, bool>> isCurrentDeviceTrusted() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final isValid = await remoteDataSource.isCurrentDeviceTrusted();
      return Right(isValid);
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, bool>> registerTrustedDevice(
      UserModel entity, DeviceInfoModel deviceInfo) async {
    try {
      final register =
          await remoteDataSource.registerTrustedDevice(entity, deviceInfo);

      return Right(register);
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, bool>> removeTrustedDevice(String imei) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final success = await remoteDataSource.removeTrustedDevice(imei);
      return Right(success);
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS: $e');
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, List<RolEntity>>> getRolesByUser(int idUsuario) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final success = await remoteDataSource.getRolesUsuario(idUsuario);
      return Right(success);
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS: $e');
      return const Right([]);
    }
  }

  @override
  Future<Either<Failure, DispositivoEntity>> getDeviceByIdentificacion(
      String identificacion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      // ignore: non_constant_identifier_names
      final UserModel =
          await remoteDataSource.getDeviceByIdentificacion(identificacion);
      if (UserModel == null) {
        return const Left(DatabaseFailure('Dispositivo no autorizado'));
      }
      return Right(UserModel);
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS: $e');
      return const Left(DatabaseFailure('Error verificando dispositivo'));
    }
  }
}
