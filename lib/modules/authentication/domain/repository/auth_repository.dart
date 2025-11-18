import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/models/deviceInfo_model.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/dispositivo_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserModel>> checkAuthStatus();
  Future<Either<Failure, UserModel>> isTrustedDevice(
      DeviceInfoModel deviceInfo);
  Future<Either<Failure, DispositivoEntity>> getDeviceByIdDispositivo(
      String idDispositivo);
  Future<Either<Failure, bool>> registerTrustedDevice(
      UserModel entity, DeviceInfoModel deviceInfo);
  Future<Either<Failure, bool>> removeTrustedDevice(String imei);
  Future<Either<Failure, List<RolEntity>>> getRolesByUser(int idUsuario);
}
