import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';

abstract class MesaRepository {
  /// Obtener todas las mesas (todas las sucursales).
  Future<Either<Failure, List<MesaEntity>>> getAllMesas();

  /// Obtener todas las mesas de una sucursal específica.
  Future<Either<Failure, List<MesaEntity>>> getMesasBySucursal(int idSucursal);

  /// Obtener una mesa por su ID.
  Future<Either<Failure, MesaEntity>> getMesaById(String idMesa);

  /// Actualizar una mesa por su ID.
  Future<Either<Failure, MesaEntity>> updateMesaById(
    String idMesa,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, MesaEntity>> createMesa(
    MesaEntity mesa,
    UserModel user,
  );

  /// Eliminar una mesa (solo administrador).
  Future<Either<Failure, bool>> deleteMesa(
    String idMesa,
    UserModel user,
  );

  /// Cambiar el estado de una mesa (ej. libre, ocupada, reservada).
  Future<Either<Failure, MesaEntity>> toggleEstadoMesa(
    String idMesa, {
    required String nuevoEstado,
  });

  /// Obtener mesas disponibles (filtrando por estado).
  Future<Either<Failure, List<MesaEntity>>> getMesasDisponibles({
    int? idSucursal,
  });
}
