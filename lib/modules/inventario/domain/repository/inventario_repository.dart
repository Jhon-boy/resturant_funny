import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';

abstract class InventarioRepository {
  /// Obtener todos los inventarios
  Future<Either<Failure, List<InventarioEntity>>> getAllInventario();

  /// Obtener inventario por ID
  Future<Either<Failure, InventarioEntity>> getInventarioById(int idInventario);

  /// Obtener inventario por sucursal
  Future<Either<Failure, List<InventarioEntity>>> getInventarioBySucursal(
      int idSucursal);

  /// Obtener inventario por sucursal
  Future<Either<Failure, List<InventarioEntity>>>
      getInventarioBySucursalPending(int idSucursal);

  /// Crear nuevo inventario
  Future<Either<Failure, InventarioEntity>> createInventario(
      InventarioEntity inventario, UserModel user);

  /// Actualizar inventario (sin tocar ID)
  Future<Either<Failure, InventarioEntity>> updateInventario(
      int idInventario, Map<String, dynamic> data);

  /// Eliminar inventario
  Future<Either<Failure, bool>> deleteInventario(int idInventario);

  /// Buscar inventario con filtros opcionales
  Future<Either<Failure, List<InventarioEntity>>> searchInventario({
    String? nombre,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? stockMin,
    int? stockMax,
    String? estado,
  });

  Future<Either<Failure, InventarioEntity>> aceptarInventario(int idInventario);
  Future<Either<Failure, InventarioEntity>> rechazarInventario(
      int idInventario);
}
