import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/ingreso_egreso_entity.dart';

abstract class IngresoEgresoRepository {
  /// Obtener todos los movimientos (opcionalmente por rango de fechas)
  Future<Either<Failure, List<IngresoEgresoEntity>>> getAllMovimientos({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  /// Obtener movimiento por ID
  Future<Either<Failure, IngresoEgresoEntity>> getMovimientoById(int idMovimiento);

  /// Obtener movimientos por sucursal (opcionalmente por rango de fechas)
  Future<Either<Failure, List<IngresoEgresoEntity>>> getMovimientosBySucursal(
    int idSucursal, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  /// Crear un nuevo movimiento
  Future<Either<Failure, IngresoEgresoEntity>> createMovimiento(
      IngresoEgresoEntity movimiento, UserModel user);

  /// Actualizar movimiento (sin tocar ID)
  Future<Either<Failure, IngresoEgresoEntity>> updateMovimiento(
      int idMovimiento, Map<String, dynamic> data);

  /// Eliminar movimiento
  Future<Either<Failure, bool>> deleteMovimiento(int idMovimiento);

  /// Buscar movimientos con filtros opcionales (incluyendo rango de fechas)
  Future<Either<Failure, List<IngresoEgresoEntity>>> searchMovimientos({
    String? tipo,
    String? categoria,
    double? montoMin,
    double? montoMax,
    String? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
}
