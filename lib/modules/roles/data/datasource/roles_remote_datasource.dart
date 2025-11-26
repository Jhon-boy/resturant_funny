import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/enhanced_auth_service.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RolesRemoteDataSource {
  final HttpClient? client;
  final WidgetRef? ref;

  RolesRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref!);

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<RolEntity>> cargarRoles() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TROL.tableName,
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => RolEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'cargarRoles');
    }
  }

  Future<RolEntity> createRol({
    required String nombre,
    required String observacion,
    required String estado,
  }) async {
    try {
      final user = EnhancedAuthService.currentUser;
      final ahora = DateTime.now();

      final data = <String, dynamic>{
        'NOMBRE': nombre,
        'OBSERVACION': observacion.isEmpty ? null : observacion,
        'ESTADO': estado,
        'FCREACION': ahora.toIso8601String(),
        if (user != null) 'USUARIOINGRESO': user.idUsuario,
      };

      final result = await SupabaseService.insert(
        table: Entities.TROL.tableName,
        data: data,
      );

      return RolEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createRol');
    }
  }

  Future<RolEntity> updateRol(
    RolEntity rol, {
    required String nombre,
    required String observacion,
    required String estado,
  }) async {
    try {
      final user = EnhancedAuthService.currentUser;
      final ahora = DateTime.now();

      final data = <String, dynamic>{
        'NOMBRE': nombre,
        'OBSERVACION': observacion.isEmpty ? null : observacion,
        'ESTADO': estado,
        'FMODIFICACION': ahora.toIso8601String(),
        if (user != null) 'USERMODIFICACION': user.idUsuario,
      };

      final result = await SupabaseService.update(
        table: Entities.TROL.tableName,
        data: data,
        filters: {'IDROL': rol.idRol},
      );

      return RolEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateRol');
    }
  }

  Future<bool> deleteRol(RolEntity rol) async {
    try {
      await SupabaseService.delete(
        table: Entities.TROL.tableName,
        filters: {'IDROL': rol.idRol},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteRol');
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
