import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VentasRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;
  VentasRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  /// Obtener todas las ventas
  Future<List<VentaEntity>> getAllVentas({
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
        table: Entities.TVENTA.tableName,
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => VentaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getAllVentas');
    }
  }

  /// Obtener ventas por sucursal
  Future<List<VentaEntity>> getVentasBySucursal(int idSucursal) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TVENTA.tableName,
        filters: {
          'IDMESA': idSucursal
        }, // Asumiendo que IDMESA referencia mesa con sucursal
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => VentaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getVentasBySucursal');
    }
  }

  /// Obtener ventas por usuario (identificación de cliente o empleado)
  Future<List<VentaEntity>> getVentasByUsuario(String identificacion) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TVENTA.tableName,
        filters: {'CLIENTE': identificacion},
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => VentaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getVentasByUsuario');
    }
  }

  /// Obtener venta por ID
  Future<VentaEntity?> getVentaById(int idVenta) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TVENTA.tableName,
        filters: {'IDVENTA': idVenta},
      );
      if (result == null) return null;
      return VentaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getVentaById');
    }
  }

  /// Crear nueva venta
  Future<VentaEntity> createVenta(VentaEntity venta, UserModel user) async {
    try {
      final data = venta.toJson();
      data['USUARIOINGRESO'] = user.idUsuario;
      final result = await SupabaseService.insert(
        table: Entities.TVENTA.tableName,
        data: data,
      );
      return VentaEntity.fromJson(result);
    } catch (e) {
      debugPrint("Error : $e");
      _handleError(e, 'createVenta');
    }
  }

  /// Actualizar venta
  Future<VentaEntity> updateVenta(
      int idVenta, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TVENTA.tableName,
        data: data,
        filters: {'IDVENTA': idVenta},
        returnData: true,
      );
      return VentaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateVenta');
    }
  }

  /// Cambiar estado de la venta
  Future<VentaEntity> toggleEstadoVenta(int idVenta, String nuevoEstado) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TVENTA.tableName,
        data: {'ESTADO': nuevoEstado},
        filters: {'IDVENTA': idVenta},
        returnData: true,
      );
      return VentaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleEstadoVenta');
    }
  }

  /// Obtener ventas por empleado con filtros de fecha

  Future<List<VentaEntity>> getVentasBy(
    int idEmpleado, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final filters = <String, dynamic>{
        'IDEMPLEADO': idEmpleado,
      };

      if (fechaDesde != null) {
        filters['FECHA_gte'] = fechaDesde.toIso8601String();
      }
      if (fechaHasta != null) {
        filters['FECHA_lte'] = fechaHasta.toIso8601String();
      }

      final result = await SupabaseService.select(
        table: Entities.TVENTA.tableName,
        filters: filters,
        orderBy: 'FECHA',
        ascending: false,
      );
      return result.map((json) => VentaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getVentasBy');
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
