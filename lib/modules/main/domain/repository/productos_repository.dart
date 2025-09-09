import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/user_entity.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';

abstract class SucursalRepository {
  Future<Either<Failure, List<ProductoEntity>>> getProductos();
  Future<Either<Failure, List<ProductoEntity>>> updateProductos(
      UserEntity user);
  Future<Either<Failure, ProductoEntity>> getProductById(String idProduct);
  Future<Either<Failure, List<ProductoEntity>>> updateProductoById(
      String idProduct);
  //solo ADMIN
  Future<Either<Failure, ProductoEntity>> createProducto(
      ProductoEntity producto, UserEntity user);
  Future<Either<Failure, List<ProductoEntity>>> deleteProducto(
      String idProduct, UserEntity user);
}
