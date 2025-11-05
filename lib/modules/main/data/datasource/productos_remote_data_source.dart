import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/main/domain/entity/producto_entity.dart';
import 'package:resturant_funny/shared/enums/categorias_producto.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductosRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  ProductosRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<ProductoEntity>> getProductos(int idSucursal,
      {bool includePorciones = false}) async {
    try {
      final filters = <String, dynamic>{'IDSUCURSAL': idSucursal};

      if (includePorciones) {
        // Si includePorciones es true, solo traer productos de categoría PORCION
        filters['CATEGORIA'] = ProductosCategorias.PORCION.code;
      } else {
        // Si includePorciones es false, traer todos los productos EXCEPTO los de categoría PORCION
        filters['CATEGORIA_neq'] = ProductosCategorias.PORCION.code;
      }

      final result = await SupabaseService.select(
        table: Entities.TPRODUCTO.tableName,
        filters: filters,
        orderBy: 'FCREACION',
        ascending: false,
      );

      return result.map((json) => ProductoEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getProductos');
    }
  }

  Future<ProductoEntity?> getProductById(String idProduct) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TPRODUCTO.tableName,
        filters: {'IDPRODUCTO': int.parse(idProduct)},
      );

      if (result == null) return null;
      return ProductoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getProductById');
    }
  }

  Future<ProductoEntity> createProducto(
      ProductoEntity producto, UserModel? user) async {
    try {
      final data = producto.toJson();
      if (user != null) data['USUARIOINGRESO'] = user.idUsuario;
      final result = await SupabaseService.insert(
        table: Entities.TPRODUCTO.tableName,
        data: data,
      );
      return ProductoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createProducto');
    }
  }

  Future<ProductoEntity> updateProductoById(
      String idProduct, Map<String, dynamic>? data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TPRODUCTO.tableName,
        data: data ?? {},
        filters: {'IDPRODUCTO': int.parse(idProduct)},
        returnData: true,
      );

      return ProductoEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateProductoById');
    }
  }

  Future<List<ProductoEntity>> updateProductos(
      List<ProductoEntity>? productos, UserModel? user) async {
    try {
      final updated = <ProductoEntity>[];
      if (productos == null) return updated;

      for (final producto in productos) {
        final data = producto.toJson();
        if (user != null) data['USUARIOMODIFICA'] = user.idUsuario;

        final result = await SupabaseService.update(
          table: Entities.TPRODUCTO.tableName,
          data: data,
          filters: {'IDPRODUCTO': producto.idProducto},
        );

        updated.addAll(result.map((json) => ProductoEntity.fromJson(json)));
      }
      return updated;
    } catch (e) {
      _handleError(e, 'updateProductos');
    }
  }

  Future<bool> deleteProducto(String idProduct, UserModel? user) async {
    try {
      await SupabaseService.delete(
        table: Entities.TPRODUCTO.tableName,
        filters: {'IDPRODUCTO': int.parse(idProduct)},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteProducto');
    }
  }

  Future<List<ProductoEntity>> searchProductos({
    String? nombre,
    String? categoria,
    bool? disponible,
    double? precioMin,
    double? precioMax,
  }) async {
    try {
      final allProducts = await SupabaseService.select(
        table: Entities.TPRODUCTO.tableName,
      );

      var filtered = allProducts;

      if (nombre != null && nombre.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['NOMBRE'] as String)
                .toLowerCase()
                .contains(nombre.toLowerCase()))
            .toList();
      }
      if (categoria != null && categoria.isNotEmpty) {
        filtered = filtered.where((p) => p['CATEGORIA'] == categoria).toList();
      }
      if (disponible != null) {
        filtered =
            filtered.where((p) => p['DISPONIBLE'] == disponible).toList();
      }
      if (precioMin != null) {
        filtered = filtered
            .where((p) => (p['PRECIO'] as num).toDouble() >= precioMin)
            .toList();
      }
      if (precioMax != null) {
        filtered = filtered
            .where((p) => (p['PRECIO'] as num).toDouble() <= precioMax)
            .toList();
      }

      return filtered.map((json) => ProductoEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'searchProductos');
    }
  }

  Future<ProductoEntity> toggleDisponibilidad(
      String idProduct, bool? disponible) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TPRODUCTO.tableName,
        data: {'DISPONIBLE': disponible ?? true},
        filters: {'IDPRODUCTO': int.parse(idProduct)},
      );
      return ProductoEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleDisponibilidad');
    }
  }

  Future<String?> uploadImagenProducto(
    String idProducto,
    Uint8List imagenBytes, {
    String? fileName,
  }) async {
    try {
      final bucket = supabase.storage.from('imagenes');
      final path = 'productos/$idProducto/${fileName ?? "default.png"}';

      await bucket.uploadBinary(path, imagenBytes,
          fileOptions: const FileOptions(upsert: true));

      return bucket.getPublicUrl(path);
    } catch (e) {
      _handleError(e, 'uploadImagenProducto');
    }
  }

  Never _handleError(dynamic error, String method) {
    if (error is SessionException) {
      throw SessionException('Error de sesión en $method: ${error.message}');
    }
    if (error is DatabaseException) {
      throw DatabaseException('Error de BD en $method: ${error.message}');
    }
    throw DatabaseException('Error inesperado en $method: $error');
  }
}
