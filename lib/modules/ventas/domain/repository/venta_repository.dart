import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';

abstract class VentaRepository {
  //Obtiene todas las ventas
  Future<Either<Failure, List<VentaEntity>>> getVentas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
//Ventas por el usuario de venta
  Future<Either<Failure, List<VentaEntity>>> getVentasBySucursal(
      int idSucursal);
  Future<Either<Failure, List<VentaEntity>>> getVentasByUsuario(
      String identificacion);

  /// Obtener venta por ID
  Future<Either<Failure, VentaEntity>> getVentaById(int idVenta);

  /// Crear una nueva venta
  Future<Either<Failure, VentaEntity>> createVenta(
      VentaEntity venta, UserModel user);

  /// Actualizar venta (sin tocar ID)
  Future<Either<Failure, VentaEntity>> updateVenta(
      int idVenta, Map<String, dynamic> data);

  /// Activar/Desactivar venta (por ejemplo cambiar estado)
  Future<Either<Failure, VentaEntity>> toggleEstadoVenta(int idVenta,
      {required String nuevoEstado});
}
