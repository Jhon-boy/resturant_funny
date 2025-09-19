import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/user/domain/entity/direccion_cliente_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DireccionClienteRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  DireccionClienteRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<DireccionClienteEntity>> getAllDirecciones() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TDIRECCION_CLIENTE.tableName,
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result
          .map((json) => DireccionClienteEntity.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'getAllDirecciones');
    }
  }

  Future<DireccionClienteEntity?> getDireccionById(int idDireccion) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TDIRECCION_CLIENTE.tableName,
        filters: {'IDDIRECCION': idDireccion},
      );
      if (result == null) return null;
      return DireccionClienteEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getDireccionById');
    }
  }

  Future<List<DireccionClienteEntity>> getDireccionesByCliente(
      String identificacion) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TDIRECCION_CLIENTE.tableName,
        filters: {'IDENTIFICACION': identificacion},
      );
      return result
          .map((json) => DireccionClienteEntity.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'getDireccionesByCliente');
    }
  }

  Future<DireccionClienteEntity> createDireccion(
      DireccionClienteEntity direccion, UserModel? user) async {
    try {
      final data = direccion.toJson();
      if (user != null) data['USUARIOINGRESO'] = user.idUsuario;
      final result = await SupabaseService.insert(
        table: Entities.TDIRECCION_CLIENTE.tableName,
        data: data,
      );
      return DireccionClienteEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createDireccion');
    }
  }

  Future<DireccionClienteEntity> updateDireccion(
      int idDireccion, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TDIRECCION_CLIENTE.tableName,
        data: data,
        filters: {'IDDIRECCION': idDireccion},
        returnData: true,
      );
      return DireccionClienteEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateDireccion');
    }
  }

  Future<bool> deleteDireccion(int idDireccion) async {
    try {
      await SupabaseService.delete(
        table: Entities.TDIRECCION_CLIENTE.tableName,
        filters: {'IDDIRECCION': idDireccion},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteDireccion');
    }
  }

  Future<DireccionClienteEntity> toggleEstadoDireccion(int idDireccion,
      {bool activo = true}) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TDIRECCION_CLIENTE.tableName,
        data: {'ESTADO': activo ? 'ACTIVO' : 'INACTIVO'},
        filters: {'IDDIRECCION': idDireccion},
      );
      return DireccionClienteEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleEstadoDireccion');
    }
  }

  Never _handleError(dynamic error, String method) {
    debugPrint('Error: $error');
    if (error is SessionException) {
      throw SessionException('Error de sesión en $method: ${error.message}');
    }
    if (error is DatabaseException) {
      throw DatabaseException('Error de BD en $method: ${error.message}');
    }
    throw DatabaseException('Error inesperado en $method: $error');
  }
}
