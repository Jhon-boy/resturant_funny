import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuariosRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  UsuariosRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<TUsuariEntity>> getUsuariosBySucursal(
    int idSucursal, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final filters = <String, dynamic>{'IDSUCURSAL': idSucursal};
      if (fechaDesde != null) {
        filters['FCREACION_gte'] = fechaDesde.toIso8601String();
      }
      if (fechaHasta != null) {
        filters['FCREACION_lte'] = fechaHasta.toIso8601String();
      }

      final result = await SupabaseService.select(
        table: Entities.TUSUARIO.tableName,
        filters: filters,
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => TUsuariEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getUsuariosBySucursal');
    }
  }

  Future<TUsuariEntity?> getUsuarioById(int idUsuario) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TUSUARIO.tableName,
        filters: {'IDUSUARIO': idUsuario},
      );
      if (result == null) return null;
      return TUsuariEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getUsuarioById');
    }
  }

  Future<TUsuariEntity?> getUsuarioByIdentificacion(
      String identificacion) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TUSUARIO.tableName,
        filters: {'IDENTIFICACION': identificacion},
      );
      if (result == null) return null;
      return TUsuariEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getUsuarioByIdentificacion');
    }
  }

  Future<TUsuariEntity> createUsuario(TUsuariEntity usuario) async {
    try {
      final data = usuario.toJson();
      final result = await SupabaseService.insert(
        table: Entities.TUSUARIO.tableName,
        data: data,
      );
      return TUsuariEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createUsuario');
    }
  }

  Future<TUsuariEntity> updateUsuario(
      int idUsuario, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TUSUARIO.tableName,
        data: data,
        filters: {'IDUSUARIO': idUsuario},
        returnData: true,
      );
      return TUsuariEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateUsuario');
    }
  }

  Future<bool> changePassword(
      int idUsuario, String oldPassword, String newPassword) async {
    try {
      // Aquí podrías validar oldPassword si tu lógica lo requiere
      final result = await SupabaseService.update(
        table: Entities.TUSUARIO.tableName,
        data: {'PASSWORD': newPassword},
        filters: {'IDUSUARIO': idUsuario},
      );
      return result.isNotEmpty;
    } catch (e) {
      _handleError(e, 'changePassword');
    }
  }

  Future<bool> resetPassword(int idUsuario, String newPassword) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TUSUARIO.tableName,
        data: {'PASSWORD': newPassword},
        filters: {'IDUSUARIO': idUsuario},
      );
      return result.isNotEmpty;
    } catch (e) {
      _handleError(e, 'resetPassword');
    }
  }

  Future<TUsuariEntity> toggleEstadoUsuario(int idUsuario,
      {bool activo = true}) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TUSUARIO.tableName,
        data: {'ESTADO': activo ? 'ACTIVO' : 'INACTIVO'},
        filters: {'IDUSUARIO': idUsuario},
        returnData: true,
      );
      return TUsuariEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleEstadoUsuario');
    }
  }

  Never _handleError(dynamic error, String method) {
    debugPrint('Error $error');
    if (error is SessionException) {
      throw SessionException('Error de sesión en $method: ${error.message}');
    }
    if (error is DatabaseException) {
      throw DatabaseException('Error de BD en $method: ${error.message}');
    }
    throw DatabaseException('Error inesperado en $method: $error');
  }
}
