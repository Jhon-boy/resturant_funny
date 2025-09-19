import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/dispositivo_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';

abstract class DispositivoRepository {
  Future<Either<Failure, List<DispositivoEntity>>> getAllDispositivos(
      {DateTime? fechaDesde, DateTime? fechaHasta});
  Future<Either<Failure, DispositivoEntity>> getDispositivoById(
      int idDispositivo);
  Future<Either<Failure, List<DispositivoEntity>>> getDispositivosByUsuario(
      int idUsuario,
      {DateTime? fechaDesde,
      DateTime? fechaHasta});
  Future<Either<Failure, DispositivoEntity>> createDispositivo(
      DispositivoEntity dispositivo, UserModel user);
  Future<Either<Failure, DispositivoEntity>> updateDispositivo(
      int idDispositivo, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteDispositivo(int idDispositivo);
}
