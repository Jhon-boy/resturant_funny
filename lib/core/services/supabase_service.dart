import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'enhanced_auth_service.dart';
import 'package:resturant_funny/app/providers/provider.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Activa el loading global
  static void _startLoading() {
    try {
      final appState = ProviderContainer().read(appStateProvider);
      appState.setLoading(true);
    } catch (e) {
      // Si no hay provider disponible, continuar sin loading
    }
  }

  /// Desactiva el loading global
  static void _stopLoading() {
    try {
      final appState = ProviderContainer().read(appStateProvider);
      appState.setLoading(false);
    } catch (e) {
      // Si no hay provider disponible, continuar sin loading
    }
  }

  /// Verifica que exista una sesión válida antes de cualquier operación
  static Future<void> _ensureAuthenticated([String? tableName]) async {
    if (!EnhancedAuthService.isLoggedIn) {
      throw SessionException(
        'Debe iniciar sesión para acceder${tableName != null ? ' a $tableName' : ''}',
      );
    }

    final isValid = await EnhancedAuthService.validateCurrentSession();
    if (!isValid) {
      throw SessionException(
          'Su sesión ha expirado. Inicie sesión nuevamente.');
    }
  }

  // =====================================
  // SELECT
  // =====================================
  static Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    _startLoading();
    debugPrint('select $table');
    try {
      await _ensureAuthenticated(table);

      PostgrestFilterBuilder query = _supabase.from(table).select(columns);

      // Aplicar filtros
      if (filters != null) {
        filters.forEach((column, value) {
          query = query.eq(column, value);
        });
      }

      // Aplicar ordenamiento y límite
      PostgrestTransformBuilder finalQuery = query;
      if (orderBy != null) {
        finalQuery = finalQuery.order(orderBy, ascending: ascending);
      }
      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final result = await finalQuery;
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      _handleDatabaseError(e, 'SELECT', table);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  static Future<Map<String, dynamic>?> selectSingle({
    required String table,
    String columns = '*',
    required Map<String, dynamic> filters,
  }) async {
    _startLoading();
    debugPrint('selectSingle $table');
    try {
      await _ensureAuthenticated(table);

      PostgrestFilterBuilder query = _supabase.from(table).select(columns);

      filters.forEach((column, value) {
        query = query.eq(column, value);
      });

      return await query.maybeSingle();
    } catch (e) {
      _handleDatabaseError(e, 'SELECT_SINGLE', table);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

//METODO LIBRE DE SELECCION A TABLAS QUE NO TENGA GUARDADO LA SESION
  static Future<Map<String, dynamic>?> selectSingleFree({
    required String table,
    String columns = '*',
    required Map<String, dynamic> filters,
  }) async {
    try {
      debugPrint('selectSingleFree $table');
      PostgrestFilterBuilder query = _supabase.from(table).select(columns);

      filters.forEach((column, value) {
        query = query.eq(column, value);
      });

      return await query.maybeSingle();
    } catch (e) {
      _handleDatabaseError(e, 'SELECT_SINGLE', table);
      rethrow;
    }
  }

  // =====================================
  // INSERT
  // =====================================
  static Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
    bool returnData = true,
  }) async {
    _startLoading();
    debugPrint('insert $table');
    try {
      await _ensureAuthenticated(table);

      if (returnData) {
        final result = await _supabase.from(table).insert(data).select();
        return Map<String, dynamic>.from(result.first);
      } else {
        await _supabase.from(table).insert(data);
        return data;
      }
    } catch (e) {
      _handleDatabaseError(e, 'INSERT', table);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  // =====================================
  // UPDATE
  // =====================================
  static Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
    bool returnData = true,
  }) async {
    _startLoading();
    debugPrint('update $table');
    try {
      await _ensureAuthenticated(table);

      PostgrestFilterBuilder query = _supabase.from(table).update(data);

      filters.forEach((column, value) {
        query = query.eq(column, value);
      });

      if (returnData) {
        final result = await query.select();
        return List<Map<String, dynamic>>.from(result);
      } else {
        await query;
        return [data];
      }
    } catch (e) {
      _handleDatabaseError(e, 'UPDATE', table);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  // =====================================
  // DELETE
  // =====================================
  static Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  }) async {
    _startLoading();
    debugPrint('delete $table');
    try {
      await _ensureAuthenticated(table);

      PostgrestFilterBuilder query = _supabase.from(table).delete();

      filters.forEach((column, value) {
        query = query.eq(column, value);
      });

      await query;
    } catch (e) {
      _handleDatabaseError(e, 'DELETE', table);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  // =====================================
  // RPC
  // =====================================
  static Future<dynamic> rpc({
    required String functionName,
    Map<String, dynamic>? params,
  }) async {
    _startLoading();
    debugPrint('rpc $functionName');
    try {
      await _ensureAuthenticated('function: $functionName');

      return await _supabase.rpc(functionName, params: params);
    } catch (e) {
      _handleDatabaseError(e, 'RPC', functionName);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  // =====================================
  // COUNT
  // =====================================
  static Future<int> count({
    required String table,
    Map<String, dynamic>? filters,
  }) async {
    _startLoading();
    debugPrint('count $table');
    try {
      await _ensureAuthenticated(table);

      final result = await select(
        table: table,
        columns: 'id',
        filters: filters,
      );

      return result.length;
    } catch (e) {
      _handleDatabaseError(e, 'COUNT', table);
      rethrow;
    } finally {
      _stopLoading();
    }
  }

  // =====================================
  // ERRORES
  // =====================================
  static void _handleDatabaseError(
      dynamic error, String operation, String resource) {
    debugPrint("Error: $error  Operacion: $operation  Resource: $resource");
    if (error is PostgrestException) {
      throw DatabaseException(
          'Error Postgrest en $operation ($resource): ${error.message}');
    }

    if (error is AuthException) {
      throw SessionException(
          'Error de autenticación en $operation ($resource): ${error.message}');
    }

    throw DatabaseException('Error en $operation ($resource): $error');
  }
}
