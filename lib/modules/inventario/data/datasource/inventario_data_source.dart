import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/inventario_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InventarioRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  InventarioRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  /// Obtener todos los inventarios
  Future<List<InventarioEntity>> getAllInventario() async {
    try {
      final result =
          await SupabaseService.select(table: Entities.TINVENTARIO.tableName);
      return result.map((json) => InventarioEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getAllInventario');
    }
  }

  /// Obtener inventario por ID
  Future<InventarioEntity?> getInventarioById(int idInventario) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TINVENTARIO.tableName,
        filters: {'IDINVENTARIO': idInventario},
      );
      if (result == null) return null;
      return InventarioEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getInventarioById');
    }
  }

  /// Obtener inventario por sucursal
  Future<List<InventarioEntity>> getInventarioBySucursal(int idSucursal) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TINVENTARIO.tableName,
        filters: {
          'IDSUCURSAL': idSucursal,
          'ESTADO': EstadosPersona.ACTIVO.getState,
        },
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => InventarioEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getInventarioBySucursal');
    }
  }

  /// Crear nuevo inventario
  Future<InventarioEntity> createInventario(
      InventarioEntity inventario, UserModel? user) async {
    try {
      final data = inventario.toJson();
      data.remove('IDINVENTARIO'); // Remove IDINVENTARIO for auto-increment
      if (user != null) data['USUARIOINGRESO'] = user.idUsuario;
      final result = await SupabaseService.insert(
        table: Entities.TINVENTARIO.tableName,
        data: data,
      );
      return InventarioEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createInventario');
    }
  }

  /// Actualizar inventario
  Future<InventarioEntity> updateInventario(
      int idInventario, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TINVENTARIO.tableName,
        data: data,
        filters: {'IDINVENTARIO': idInventario},
        returnData: true,
      );
      return InventarioEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateInventario');
    }
  }

  Future<bool> deleteInventario(int idInventario) async {
    try {
      await SupabaseService.update(
        table: Entities.TINVENTARIO.tableName,
        data: {'ESTADO': EstadosPersona.INACTIVO.getState},
        filters: {'IDINVENTARIO': idInventario},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteInventario');
    }
  }

  /// Buscar inventario con filtros opcionales
  Future<List<InventarioEntity>> searchInventario({
    String? nombre,
    String? categoria,
    double? precioMin,
    double? precioMax,
    int? stockMin,
    int? stockMax,
    String? estado,
  }) async {
    try {
      final allInventarios = await SupabaseService.select(
        table: Entities.TINVENTARIO.tableName,
      );

      var filtered = allInventarios;

      if (nombre != null && nombre.isNotEmpty) {
        filtered = filtered
            .where((i) => (i['NOMBRE'] as String)
                .toLowerCase()
                .contains(nombre.toLowerCase()))
            .toList();
      }

      if (categoria != null && categoria.isNotEmpty) {
        filtered = filtered
            .where((i) =>
                (i['CATEGORIA'] as String).toLowerCase() ==
                categoria.toLowerCase())
            .toList();
      }

      if (precioMin != null) {
        filtered = filtered
            .where((i) => (i['PRECIO_UNITARIO'] as num).toDouble() >= precioMin)
            .toList();
      }

      if (precioMax != null) {
        filtered = filtered
            .where((i) => (i['PRECIO_UNITARIO'] as num).toDouble() <= precioMax)
            .toList();
      }

      if (stockMin != null) {
        filtered = filtered
            .where((i) => (i['STOCK'] as num).toInt() >= stockMin)
            .toList();
      }

      if (stockMax != null) {
        filtered = filtered
            .where((i) => (i['STOCK'] as num).toInt() <= stockMax)
            .toList();
      }

      if (estado != null && estado.isNotEmpty) {
        filtered = filtered
            .where((i) =>
                (i['ESTADO'] as String).toLowerCase() == estado.toLowerCase())
            .toList();
      }

      return filtered.map((json) => InventarioEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'searchInventario');
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
