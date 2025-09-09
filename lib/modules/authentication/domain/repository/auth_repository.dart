import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/models/deviceInfo_model.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> checkAuthStatus();
  Future<Either<Failure, UserEntity>> isTrustedDevice(DeviceInfoModel deviceInfo);
  Future<Either<Failure, bool>> registerTrustedDevice(UserEntity entity);
  Future<Either<Failure, bool>> removeTrustedDevice(String imei);
  Future<Either<Failure, List<RolEntity>>> getRolesByUser(int idUsuario);
}
