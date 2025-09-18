import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/services/conection_service.dart';
import 'package:resturant_funny/core/utils/either.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/main/data/datasource/productos_remote_data_source.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/modules/main/domain/repository/productos_repository.dart';

class ProductosRepositoryImpl implements ProductosRepository {
  final ProductosRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  ProductosRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, ProductoEntity>> createProducto(
      ProductoEntity producto, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final product = await remote.createProducto(producto, user);
      return Right(product);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProducto(
      String idProduct, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final delete = await remote.deleteProducto(idProduct, user);
      return Right(delete);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> getProductos(
      int idSucursal) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final productos = await remote.getProductos(idSucursal);
      return Right(productos);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, ProductoEntity>> getProductById(
      String idProduct) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }

    try {
      final producto = await remote.getProductById(idProduct);
      if (producto == null) {
        return const Left(ServerFailure('Producto no encontrado'));
      }
      return Right(producto);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, ProductoEntity>> updateProductoById(
      String idProduct, Map<String, dynamic> data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final updateProduct = await remote.updateProductoById(idProduct, data);
      return Right(updateProduct);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> getProductosPaged({
    required int idSucursal,
    int limit = 10,
    int offset = 0,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.getProductos(idSucursal);
      final paged = result.skip(offset).take(limit).toList();
      return Right(paged);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<ProductoEntity>>> searchProductos({
    String? nombre,
    String? categoria,
    bool? disponible,
    double? precioMin,
    double? precioMax,
  }) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.searchProductos(
        nombre: nombre,
        categoria: categoria,
        disponible: disponible,
        precioMin: precioMin,
        precioMax: precioMax,
      );
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  @override
  Future<Either<Failure, ProductoEntity>> toggleDisponibilidad(String idProduct,
      {bool disponible = true}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.toggleDisponibilidad(idProduct, disponible);
      return Right(result);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImagenProducto(
      String idProducto, Uint8List imagenBytes,
      {String? fileName}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final url = await remote.uploadImagenProducto(
        idProducto,
        imagenBytes,
        fileName: fileName,
      );
      if (url == null) {
        return const Left(ServerFailure('No se pudo subir la imagen'));
      }
      return Right(url);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
