import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';

abstract class ProductosRepository {
  /// Obtener todos los productos de una sucursal.
  Future<Either<Failure, List<ProductoEntity>>> getProductos(int idSucursal);

  /// Obtener un producto específico por su ID.
  Future<Either<Failure, ProductoEntity>> getProductById(String idProduct);

  /// Actualizar un producto específico por su ID.
  Future<Either<Failure, ProductoEntity>> updateProductoById(
    String idProduct,  Map<String, dynamic> data
  );

  /// Crear un nuevo producto (solo administrador).
  Future<Either<Failure, ProductoEntity>> createProducto(
    ProductoEntity producto,
    UserModel user,
  );

  /// Eliminar un producto (solo administrador).
  Future<Either<Failure, bool>> deleteProducto(
    String idProduct,
    UserModel user,
  );

  /// Buscar productos por filtros opcionales.
  Future<Either<Failure, List<ProductoEntity>>> searchProductos({
    String? nombre,
    String? categoria,
    bool? disponible,
    double? precioMin,
    double? precioMax,
  });

  /// Obtener productos de forma paginada.
  Future<Either<Failure, List<ProductoEntity>>> getProductosPaged({
    required int idSucursal,
    int limit = 10,
    int offset = 0,
  });

  /// Subir una imagen de producto al almacenamiento.
  /// Retorna la URL pública de la imagen.
  Future<Either<Failure, String>> uploadImagenProducto(
    String idProducto,
    Uint8List imagenBytes, {
    String? fileName,
  });

  /// Cambiar rápidamente la disponibilidad de un producto.
  Future<Either<Failure, ProductoEntity>> toggleDisponibilidad(
    String idProduct, {
    bool disponible = true,
  });
}
