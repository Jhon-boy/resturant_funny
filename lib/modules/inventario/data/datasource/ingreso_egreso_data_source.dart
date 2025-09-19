import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/inventario/domain/entity/ingreso_egreso_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IngresoEgresoRemoteDataSource {
  final WidgetRef ref;

  IngresoEgresoRemoteDataSource({required this.ref});
  final SupabaseClient supabase = Supabase.instance.client;

  /// Obtener todos los movimientos con filtros opcionales por fechas
  Future<List<IngresoEgresoEntity>> getMovimientos({
    int? idSucursal,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (idSucursal != null) filters['IDSUCURSAL'] = idSucursal;
      if (fechaDesde != null) {
        filters['FECHA_gte'] = fechaDesde.toIso8601String();
      }
      if (fechaHasta != null) {
        filters['FECHA_lte'] = fechaHasta.toIso8601String();
      }

      final result = await SupabaseService.select(
        table: Entities.TINGRESO_EGRESO.tableName,
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'FECHA',
        ascending: false,
      );

      return result.map((json) => IngresoEgresoEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getMovimientos');
    }
  }

  /// Obtener movimiento por ID
  Future<IngresoEgresoEntity?> getMovimientoById(int idMovimiento) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TINGRESO_EGRESO.tableName,
        filters: {'IDMOVIMIENTO': idMovimiento},
      );
      if (result == null) return null;
      return IngresoEgresoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getMovimientoById');
    }
  }

  /// Crear un nuevo movimiento
  Future<IngresoEgresoEntity> createMovimiento(
      IngresoEgresoEntity movimiento, UserModel user) async {
    try {
      final data = movimiento.toJson();
      data['USUARIOINGRESO'] = user.idUsuario;
      final result = await SupabaseService.insert(
        table: Entities.TINGRESO_EGRESO.tableName,
        data: data,
      );
      return IngresoEgresoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createMovimiento');
    }
  }

  /// Actualizar movimiento
  Future<IngresoEgresoEntity> updateMovimiento(
      int idMovimiento, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TINGRESO_EGRESO.tableName,
        data: data,
        filters: {'IDMOVIMIENTO': idMovimiento},
        returnData: true,
      );
      return IngresoEgresoEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateMovimiento');
    }
  }

  /// Eliminar movimiento
  Future<bool> deleteMovimiento(int idMovimiento) async {
    try {
      await SupabaseService.delete(
        table: Entities.TINGRESO_EGRESO.tableName,
        filters: {'IDMOVIMIENTO': idMovimiento},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteMovimiento');
    }
  }

  /// Buscar movimientos con filtros opcionales, incluyendo fechas
  Future<List<IngresoEgresoEntity>> searchMovimientos({
    String? tipo,
    String? categoria,
    double? montoMin,
    double? montoMax,
    String? estado,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final allMovimientos = await SupabaseService.select(
        table: Entities.TINGRESO_EGRESO.tableName,
      );

      var filtered = allMovimientos;

      if (tipo != null && tipo.isNotEmpty) {
        filtered = filtered.where((m) => m['TIPO'] == tipo).toList();
      }
      if (categoria != null && categoria.isNotEmpty) {
        filtered = filtered.where((m) => m['CATEGORIA'] == categoria).toList();
      }
      if (montoMin != null) {
        filtered = filtered
            .where((m) => (m['MONTO'] as num).toDouble() >= montoMin)
            .toList();
      }
      if (montoMax != null) {
        filtered = filtered
            .where((m) => (m['MONTO'] as num).toDouble() <= montoMax)
            .toList();
      }
      if (estado != null && estado.isNotEmpty) {
        filtered = filtered.where((m) => m['ESTADO'] == estado).toList();
      }
      if (fechaDesde != null) {
        filtered = filtered
            .where((m) => DateTime.parse(m['FECHA'])
                .isAfter(fechaDesde.subtract(const Duration(seconds: 1))))
            .toList();
      }
      if (fechaHasta != null) {
        filtered = filtered
            .where((m) => DateTime.parse(m['FECHA'])
                .isBefore(fechaHasta.add(const Duration(seconds: 1))))
            .toList();
      }

      return filtered
          .map((json) => IngresoEgresoEntity.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'searchMovimientos');
    }
  }

  Never _handleError(dynamic error, String method) {
    debugPrint('Error: $error');
    throw DatabaseException('Error en $method: $error');
  }
}
