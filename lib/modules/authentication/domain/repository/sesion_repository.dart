import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/sesion_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';

abstract class SesionRepository {
  Future<Either<Failure, List<SesionEntity>>> getAllSesiones(
      DateTime? fechaDesde, DateTime? fechaHasta);
  Future<Either<Failure, SesionEntity>> getSesionById(String idSesion);
  Future<Either<Failure, List<SesionEntity>>> getSesionesByUsuario(
      int idUsuario,
      {DateTime? fechaDesde,
      DateTime? fechaHasta});
  Future<Either<Failure, SesionEntity>> createSesion(
      SesionEntity sesion, UserModel user); 
}
