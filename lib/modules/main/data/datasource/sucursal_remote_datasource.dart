import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SucursalRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  SucursalRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);
  final SupabaseClient supabase = Supabase.instance.client;

  /// OBTENER TODAS LAS SUCURSALES
  Future<List<SucursalEntity>> getSucursales() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSUCURSAL.tableName,
        orderBy: 'FCREACION',
        ascending: false,
      );

      return result.map((json) => SucursalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getSucursales');
    }
  }

  /// OBTENER SUCURSAL POR ID
  Future<SucursalEntity?> getSucursalById(int idSucursal) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TSUCURSAL.tableName,
        filters: {'IDSUCURSAL': idSucursal},
      );

      if (result == null) return null;
      return SucursalEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getSucursalById');
    }
  }

  /// OBTENER SUCURSALES ACTIVAS
  Future<List<SucursalEntity>> getSucursalesActivas() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSUCURSAL.tableName,
        filters: {'ESTADO': true},
        orderBy: 'NOMBRE',
        ascending: true,
      );

      return result.map((json) => SucursalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getSucursalesActivas');
    }
  }

  /// REGISTRAR NUEVA SUCURSAL
  Future<SucursalEntity> createSucursal(SucursalEntity sucursal) async {
    try {
      final data = {
        'NOMBRE': sucursal.nombre,
        'DIRECCION': sucursal.direccion,
        'ESTADO': sucursal.estado ?? true,
        'FCREACION': DateTime.now().toIso8601String(),
        'USUARIOINGRESO': sucursal.usuarioIngreso,
      };

      final result = await SupabaseService.insert(
        table: Entities.TSUCURSAL.tableName,
        data: data,
      );

      return SucursalEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createSucursal');
    }
  }

  /// ACTUALIZAR SUCURSAL
  Future<SucursalEntity> updateSucursal(SucursalEntity sucursal) async {
    try {
      final data = {
        'NOMBRE': sucursal.nombre,
        'DIRECCION': sucursal.direccion,
        'ESTADO': sucursal.estado,
        'FMODIFICACION': DateTime.now().toIso8601String(),
        'USERMODIFICACION': sucursal.userModificacion,
      };

      final result = await SupabaseService.update(
        table: Entities.TSUCURSAL.tableName,
        data: data,
        filters: {'IDSUCURSAL': sucursal.idSucursal},
      );

      return SucursalEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateSucursal');
    }
  }

  /// ELIMINAR SUCURSAL (SOFT DELETE - CAMBIAR ESTADO A FALSE)
  Future<bool> deleteSucursal(int idSucursal, String userModificacion) async {
    try {
      await SupabaseService.update(
        table: Entities.TSUCURSAL.tableName,
        data: {
          'ESTADO': false,
          'FMODIFICACION': DateTime.now().toIso8601String(),
          'USERMODIFICACION': userModificacion,
        },
        filters: {'IDSUCURSAL': idSucursal},
      );

      return true;
    } catch (e) {
      _handleError(e, 'deleteSucursal');
    }
  }

  /// ELIMINAR SUCURSAL PERMANENTEMENTE (HARD DELETE)
  Future<bool> deleteSucursalPermanently(int idSucursal) async {
    try {
      await SupabaseService.delete(
        table: Entities.TSUCURSAL.tableName,
        filters: {'IDSUCURSAL': idSucursal},
      );

      return true;
    } catch (e) {
      _handleError(e, 'deleteSucursalPermanently');
    }
  }

  /// BUSCAR SUCURSALES POR NOMBRE
  Future<List<SucursalEntity>> searchSucursalesByName(String nombre) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSUCURSAL.tableName,
        filters: {
          'NOMBRE': {'ilike': '%$nombre%'}
        },
        orderBy: 'NOMBRE',
        ascending: true,
      );

      return result.map((json) => SucursalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'searchSucursalesByName');
    }
  }

  /// ACTIVAR/DESACTIVAR SUCURSAL
  Future<bool> toggleSucursalEstado(
      int idSucursal, bool estado, String userModificacion) async {
    try {
      await SupabaseService.update(
        table: Entities.TSUCURSAL.tableName,
        data: {
          'ESTADO': estado,
          'FMODIFICACION': DateTime.now().toIso8601String(),
          'USERMODIFICACION': userModificacion,
        },
        filters: {'IDSUCURSAL': idSucursal},
      );

      return true;
    } catch (e) {
      _handleError(e, 'toggleSucursalEstado');
    }
  }

  /// OBTENER ESTADÍSTICAS DE SUCURSALES
  Future<Map<String, dynamic>> getSucursalesEstadisticas() async {
    try {
      final allSucursales = await getSucursales();
      final activas = allSucursales.where((s) => s.estado == true).length;
      final inactivas = allSucursales.where((s) => s.estado == false).length;

      return {
        'total': allSucursales.length,
        'activas': activas,
        'inactivas': inactivas,
        'ultimaActualizacion': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _handleError(e, 'getSucursalesEstadisticas');
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
