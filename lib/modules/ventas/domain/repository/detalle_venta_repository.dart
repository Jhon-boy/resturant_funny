import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/detalle_venta_entity.dart';

abstract class DetalleVentaRepository {
  /// Obtener todos los detalles de venta
  Future<Either<Failure, List<DetalleVentaEntity>>> getAllDetalles({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  /// Obtener detalles de venta por ID de venta
  Future<Either<Failure, List<DetalleVentaEntity>>> getDetallesByVenta(
      int idVenta);

  /// Obtener detalle por ID
  Future<Either<Failure, DetalleVentaEntity>> getDetalleById(int idDetalle);

  /// Crear un nuevo detalle de venta
  Future<Either<Failure, DetalleVentaEntity>> createDetalle(
      DetalleVentaEntity detalle, UserModel user);

  /// Actualizar un detalle de venta (sin tocar IDDETALLE)
  Future<Either<Failure, DetalleVentaEntity>> updateDetalle(
      int idDetalle, Map<String, dynamic> data);

  /// Eliminar un detalle de venta
  Future<Either<Failure, bool>> deleteDetalle(int idDetalle);

  /// Obtener detalles de venta con información de productos, filtrado por IDs de venta
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getDetallesConProductosBySucursal(
    List<int> idsVentas, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });
}
