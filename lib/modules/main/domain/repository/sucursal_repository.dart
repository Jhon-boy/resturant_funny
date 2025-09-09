import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';

abstract class SucursalRepository {
  Future<Either<Failure, SucursalEntity>> getSucursalEntity();
}
