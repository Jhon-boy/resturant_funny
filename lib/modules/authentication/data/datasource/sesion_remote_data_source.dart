import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/sesion_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionRemoteDataSource {
  final WidgetRef ref;
  SessionRemoteDataSource({required this.ref});
  final SupabaseClient supabase = Supabase.instance.client;

  /// Crear una nueva sesión
  Future<bool> createSesion(SesionEntity sesion) async {
    try {
      final data = sesion.toJson();
      data['FCREACION'] = AppUtils.getFechaActual().toIso8601String();
      data.remove('IDSESION');
      await SupabaseService.insert(
        table: Entities.TSESION.tableName,
        data: data,
      );
      return true;
    } catch (e) {
      _handleError(e, 'createSesion');
    }
  }

  /// Obtener todas las sesiones
  Future<List<SesionEntity>> getAllSesions(
      DateTime fechaDesde, DateTime fechaHasta) async {
    try {
      final result = await SupabaseService.select(
          table: Entities.TSESION.tableName,
          ascending: true,
          filters: {
            'FCREACION_gte': fechaDesde.toIso8601String(),
            'FCREACION_lte': fechaHasta.toIso8601String(),
          });
      return result.map((json) => SesionEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getMovimientos');
    }
  }

  Future<SesionEntity?> getSesionById(String idSesion) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TSESION.tableName,
        filters: {'IDSESION': idSesion},
      );
      if (result == null) return null;
      return SesionEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getSesionById');
    }
  }

  /// Obtener sesiones por usuario
  Future<List<SesionEntity>> getSesionesByUsuario(
      int idUsuario, DateTime fechaDesde, DateTime fechaHasta) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSESION.tableName,
        filters: {
          'IDUSUARIO': idUsuario,
          'FCREACION_gte': fechaDesde.toIso8601String(),
          'FCREACION_lte': fechaHasta.toIso8601String(),
        },
      );
      return result.map((json) => SesionEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getSesionesByUsuario');
    }
  }

  Never _handleError(dynamic error, String method) {
    debugPrint('Error: $error');
    throw DatabaseException('Error en $method: $error');
  }
}
