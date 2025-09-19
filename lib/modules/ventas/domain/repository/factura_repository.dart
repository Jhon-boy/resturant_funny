import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/factura_entity.dart';

abstract class FacturasRepository {
  /// Obtener todas las facturas
  Future<Either<Failure, List<FacturaEntity>>> getAllFacturas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  /// Obtener factura por ID
  Future<Either<Failure, FacturaEntity>> getFacturaById(int idFactura);

  /// Obtener factura por número de factura
  Future<Either<Failure, FacturaEntity>> getFacturaByNumero(
      String numeroFactura);

  /// Obtener facturas por cliente
  Future<Either<Failure, List<FacturaEntity>>> getFacturasByCliente(
      String idCliente);

  /// Crear una nueva factura
  Future<Either<Failure, FacturaEntity>> createFactura(
      FacturaEntity factura, UserModel user);

  /// Actualizar factura (sin tocar IDFACTURA ni IDVENTA)
  Future<Either<Failure, FacturaEntity>> updateFactura(
      int idFactura, Map<String, dynamic> data);

  /// Eliminar factura
  Future<Either<Failure, bool>> deleteFactura(int idFactura);

  /// Buscar facturas con filtros opcionales
  Future<Either<Failure, List<FacturaEntity>>> searchFacturas({
    String? numeroFactura,
    String? idCliente,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    double? totalMin,
    double? totalMax,
  });
}
