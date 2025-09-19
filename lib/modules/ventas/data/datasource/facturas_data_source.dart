import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/factura_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FacturasRemoteDataSource {
  final WidgetRef ref;

  FacturasRemoteDataSource({required this.ref});

  final SupabaseClient supabase = Supabase.instance.client;

  /// Obtener todas las facturas
  Future<List<FacturaEntity>> getAllFacturas({
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
        table: Entities.TFACTURA.tableName,
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => FacturaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getAllFacturas');
    }
  }

  /// Obtener factura por ID
  Future<FacturaEntity?> getFacturaById(int idFactura) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TFACTURA.tableName,
        filters: {'IDFACTURA': idFactura},
      );
      if (result == null) return null;
      return FacturaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getFacturaById');
    }
  }

  /// Obtener factura por número
  Future<FacturaEntity?> getFacturaByNumero(String numeroFactura) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TFACTURA.tableName,
        filters: {'NUMEROFACTURA': numeroFactura},
      );
      if (result == null) return null;
      return FacturaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getFacturaByNumero');
    }
  }

  /// Obtener facturas por cliente
  Future<List<FacturaEntity>> getFacturasByCliente(String idCliente) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TFACTURA.tableName,
        filters: {'IDCLIENTE': idCliente},
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => FacturaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getFacturasByCliente');
    }
  }

  /// Crear nueva factura
  Future<FacturaEntity> createFactura(
      FacturaEntity factura, UserModel user) async {
    try {
      final data = factura.toJson();
      data['USUARIOINGRESO'] = user.idUsuario;
      final result = await SupabaseService.insert(
        table: Entities.TFACTURA.tableName,
        data: data,
      );
      return FacturaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createFactura');
    }
  }

  /// Actualizar factura
  Future<FacturaEntity> updateFactura(
      int idFactura, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TFACTURA.tableName,
        data: data,
        filters: {'IDFACTURA': idFactura},
        returnData: true,
      );
      return FacturaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateFactura');
    }
  }

  /// Eliminar factura
  Future<bool> deleteFactura(int idFactura) async {
    try {
      await SupabaseService.delete(
        table: Entities.TFACTURA.tableName,
        filters: {'IDFACTURA': idFactura},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteFactura');
    }
  }

  /// Buscar facturas con filtros opcionales
  Future<List<FacturaEntity>> searchFacturas({
    String? numeroFactura,
    String? idCliente,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    double? totalMin,
    double? totalMax,
  }) async {
    try {
      final allFacturas = await SupabaseService.select(
        table: Entities.TFACTURA.tableName,
      );

      var filtered = allFacturas;

      if (numeroFactura != null && numeroFactura.isNotEmpty) {
        filtered = filtered
            .where((f) => (f['NUMEROFACTURA'] as String)
                .toLowerCase()
                .contains(numeroFactura.toLowerCase()))
            .toList();
      }
      if (idCliente != null && idCliente.isNotEmpty) {
        filtered = filtered.where((f) => f['IDCLIENTE'] == idCliente).toList();
      }
      if (fechaDesde != null) {
        filtered = filtered
            .where((f) => DateTime.parse(f['FECHA']).isAfter(fechaDesde))
            .toList();
      }
      if (fechaHasta != null) {
        filtered = filtered
            .where((f) => DateTime.parse(f['FECHA']).isBefore(fechaHasta))
            .toList();
      }
      if (totalMin != null) {
        filtered = filtered
            .where((f) => (f['TOTAL'] as num).toDouble() >= totalMin)
            .toList();
      }
      if (totalMax != null) {
        filtered = filtered
            .where((f) => (f['TOTAL'] as num).toDouble() <= totalMax)
            .toList();
      }

      return filtered.map((json) => FacturaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'searchFacturas');
    }
  }

  Never _handleError(dynamic error, String method) {
    debugPrint('Error:  $error');
    if (error is SessionException) {
      throw SessionException('Error de sesión en $method: ${error.message}');
    }
    if (error is DatabaseException) {
      throw DatabaseException('Error de BD en $method: ${error.message}');
    }
    throw DatabaseException('Error inesperado en $method: $error');
  }
}
