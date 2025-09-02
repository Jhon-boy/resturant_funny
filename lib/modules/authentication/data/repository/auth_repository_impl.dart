// ignore_for_file: unrelated_type_equality_checks

import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/user_entity.dart';
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
  Future<Either<Failure, UserEntity>> login(
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
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkAuthStatus() async {
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
    } catch (_) {
      return const Left(ServerFailure('Unexpected error in logout'));
    }
  }
}
