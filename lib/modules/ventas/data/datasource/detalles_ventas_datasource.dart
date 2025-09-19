import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/detalle_venta_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetalleVentaRemoteDataSource {
  final WidgetRef ref;

  DetalleVentaRemoteDataSource({required this.ref});

  final SupabaseClient supabase = Supabase.instance.client;

  /// Obtener todos los detalles de venta
  Future<List<DetalleVentaEntity>> getAllDetalles({
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
        table: 'TDETALLEVENTA',
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => DetalleVentaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getAllDetalles');
    }
  }

  /// Obtener detalles por ID de venta
  Future<List<DetalleVentaEntity>> getDetallesByVenta(int idVenta) async {
    try {
      final result = await SupabaseService.select(
        table: 'TDETALLEVENTA',
        filters: {'IDVENTA': idVenta},
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => DetalleVentaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getDetallesByVenta');
    }
  }

  /// Obtener detalle por ID
  Future<DetalleVentaEntity?> getDetalleById(int idDetalle) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: 'TDETALLEVENTA',
        filters: {'IDDETALLE': idDetalle},
      );
      if (result == null) return null;
      return DetalleVentaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getDetalleById');
    }
  }

  /// Crear un nuevo detalle de venta
  Future<DetalleVentaEntity> createDetalle(
      DetalleVentaEntity detalle, UserModel user) async {
    try {
      final data = detalle.toJson();
      data['USUARIOINGRESO'] = user.idUsuario;
      final result = await SupabaseService.insert(
        table: 'TDETALLEVENTA',
        data: data,
      );
      return DetalleVentaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createDetalle');
    }
  }

  /// Actualizar detalle por ID
  Future<DetalleVentaEntity> updateDetalle(
      int idDetalle, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: 'TDETALLEVENTA',
        data: data,
        filters: {'IDDETALLE': idDetalle},
        returnData: true,
      );
      return DetalleVentaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateDetalle');
    }
  }

  /// Eliminar detalle
  Future<bool> deleteDetalle(int idDetalle) async {
    try {
      await SupabaseService.delete(
        table: 'TDETALLEVENTA',
        filters: {'IDDETALLE': idDetalle},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteDetalle');
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
