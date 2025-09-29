import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonasRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  PersonasRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  /// Obtener todas las personas
  Future<List<PersonaEntity>> getPersonas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (fechaDesde != null) {
        filters['FCREACION_gte'] = fechaDesde.toIso8601String();
      }
      if (fechaHasta != null) {
        filters['FCREACION_lte'] = fechaHasta.toIso8601String();
      }

      final result = await SupabaseService.select(
        table: Entities.TPERSONA.tableName,
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => PersonaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getPersonas');
    }
  }

  /// Obtener persona por ID
  Future<PersonaEntity?> getPersonaById(String idPersona) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TPERSONA.tableName,
        filters: {'IDENTIFICACION': idPersona},
      );
      if (result == null) return null;
      return PersonaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getPersonaById');
    }
  }

  /// Crear nueva persona
  Future<PersonaEntity> createPersona(
      PersonaEntity persona, UserModel? user) async {
    try {
      final data = persona.toJson();
      if (user != null) data['USUARIOINGRESO'] = user.idUsuario;

      final result = await SupabaseService.insert(
        table: Entities.TPERSONA.tableName,
        data: data,
      );
      return PersonaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createPersona');
    }
  }

  /// Actualizar persona por ID
  Future<PersonaEntity> updatePersonaById(
      String idPersona, Map<String, dynamic>? data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TPERSONA.tableName,
        data: data ?? {},
        filters: {'IDPERSONA': int.parse(idPersona)},
        returnData: true,
      );
      return PersonaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updatePersonaById');
    }
  }

  /// Eliminar persona
  Future<bool> deletePersona(String idPersona, UserModel? user) async {
    try {
      await SupabaseService.delete(
        table: Entities.TPERSONA.tableName,
        filters: {'IDPERSONA': int.parse(idPersona)},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deletePersona');
    }
  }

  /// Buscar personas por filtros opcionales
  Future<List<PersonaEntity>> searchPersonas({
    String? nombres,
    String? apellidos,
    String? correo,
    String? telefono,
    bool? activo,
  }) async {
    try {
      final allPersonas = await SupabaseService.select(
        table: Entities.TPERSONA.tableName,
      );

      var filtered = allPersonas;
      if (nombres != null && nombres.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['NOMBRES'] as String)
                .toLowerCase()
                .contains(nombres.toLowerCase()))
            .toList();
      }
      if (apellidos != null && apellidos.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['APELLIDOS'] as String)
                .toLowerCase()
                .contains(apellidos.toLowerCase()))
            .toList();
      }
      if (correo != null && correo.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['CORREO'] as String)
                .toLowerCase()
                .contains(correo.toLowerCase()))
            .toList();
      }
      if (telefono != null && telefono.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['TELEFONO'] as String)
                .toLowerCase()
                .contains(telefono.toLowerCase()))
            .toList();
      }
      if (activo != null) {
        filtered = filtered.where((p) => p['ACTIVO'] == activo).toList();
      }

      return filtered.map((json) => PersonaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'searchPersonas');
    }
  }

  /// Cambiar estado de persona
  Future<PersonaEntity> toggleEstadoPersona(
      String idPersona, bool? activo) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TPERSONA.tableName,
        data: {'ACTIVO': activo ?? true},
        filters: {'IDPERSONA': int.parse(idPersona)},
      );
      return PersonaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleEstadoPersona');
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
