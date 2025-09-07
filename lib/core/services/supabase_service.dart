import 'package:resturant_funny/core/errors/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'enhanced_auth_service.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

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
    await _ensureAuthenticated(table);

    try {
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
    }
  }

  static Future<Map<String, dynamic>?> selectSingle({
    required String table,
    String columns = '*',
    required Map<String, dynamic> filters,
  }) async {
    await _ensureAuthenticated(table);

    try {
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
    await _ensureAuthenticated(table);

    try {
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
    await _ensureAuthenticated(table);

    try {
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
    }
  }

  // =====================================
  // DELETE
  // =====================================
  static Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  }) async {
    await _ensureAuthenticated(table);

    try {
      PostgrestFilterBuilder query = _supabase.from(table).delete();

      filters.forEach((column, value) {
        query = query.eq(column, value);
      });

      await query;
    } catch (e) {
      _handleDatabaseError(e, 'DELETE', table);
      rethrow;
    }
  }

  // =====================================
  // RPC
  // =====================================
  static Future<dynamic> rpc({
    required String functionName,
    Map<String, dynamic>? params,
  }) async {
    await _ensureAuthenticated('function: $functionName');

    try {
      return await _supabase.rpc(functionName, params: params);
    } catch (e) {
      _handleDatabaseError(e, 'RPC', functionName);
      rethrow;
    }
  }

  // =====================================
  // COUNT
  // =====================================
  static Future<int> count({
    required String table,
    Map<String, dynamic>? filters,
  }) async {
    await _ensureAuthenticated(table);

    try {
      // Usar una consulta simple para contar registros
      final result = await select(
        table: table,
        columns: 'id', // Solo seleccionar una columna para optimizar
        filters: filters,
      );

      return result.length;
    } catch (e) {
      _handleDatabaseError(e, 'COUNT', table);
      rethrow;
    }
  }

  // =====================================
  // ERRORES
  // =====================================
  static void _handleDatabaseError(
      dynamic error, String operation, String resource) {
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
