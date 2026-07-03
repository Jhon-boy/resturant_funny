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

  /// Obtener detalles de venta con información de productos, filtrado por sucursal y fechas
  /// Retorna una lista de mapas con información del detalle y del producto
  Future<List<Map<String, dynamic>>> getDetallesConProductosBySucursal({
    required int idSucursal,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      // Primero obtener las mesas de la sucursal
      final mesasResult = await SupabaseService.select(
        table: 'TMESA',
        filters: {'IDSUCURSAL': idSucursal},
      );

      if (mesasResult.isEmpty) {
        return [];
      }

      final idsMesas = mesasResult.map((m) => m['IDMESA'] as int).toList();

      // Obtener ventas de esas mesas
      final filtersVenta = <String, dynamic>{};
      if (fechaDesde != null) {
        filtersVenta['FECHA_gte'] = fechaDesde.toIso8601String();
      }
      if (fechaHasta != null) {
        filtersVenta['FECHA_lte'] = fechaHasta.toIso8601String();
      }

      // Obtener todas las ventas que corresponden a las mesas de la sucursal
      final ventasResult = await SupabaseService.select(
        table: 'TVENTA',
        filters: filtersVenta.isNotEmpty ? filtersVenta : null,
      );

      final idsVentas = ventasResult
          .where((v) => idsMesas.contains(v['IDMESA'] as int))
          .map((v) => v['IDVENTA'] as int)
          .toList();

      if (idsVentas.isEmpty) {
        return [];
      }

      // Obtener detalles de venta con información del producto usando join
      final query = supabase.from('TDETALLEVENTA').select('''
            IDDETALLE,
            IDVENTA,
            IDPRODUCTO,
            CANTIDAD,
            METODOPAGO,
            PRECIO_UNITARIO,
            SUBTOTAL,
            FCREACION,
            TPRODUCTO!TDETALLEVENTA_IDPRODUCTO_fkey (
              IDPRODUCTO,
              IDSUCURSAL,
              NOMBRE,
              DESCRIPCION,
              PRECIO,
              CATEGORIA,
              DISPONIBLE,
              ESTADO
            )
          ''');

      // Filtrar por IDs de venta usando OR
      PostgrestFilterBuilder filteredQuery = query;
      if (idsVentas.isNotEmpty) {
        filteredQuery =
            filteredQuery.or(idsVentas.map((id) => 'IDVENTA.eq.$id').join(','));
      } else {
        return [];
      }

      // Aplicar filtros de fecha si existen
      if (fechaDesde != null) {
        filteredQuery =
            filteredQuery.gte('FCREACION', fechaDesde.toIso8601String());
      }
      if (fechaHasta != null) {
        filteredQuery =
            filteredQuery.lte('FCREACION', fechaHasta.toIso8601String());
      }

      final result = await filteredQuery;

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      _handleError(e, 'getDetallesConProductosBySucursal');
    }
  }

  /// Obtener detalles de venta con información de productos, filtrado por IDs de venta
  Future<List<Map<String, dynamic>>> getDetallesConProductosByVentas({
    required List<int> idsVentas,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      if (idsVentas.isEmpty) {
        return [];
      }

      // Obtener detalles de venta con información del producto usando join
      final query = supabase.from('TDETALLEVENTA').select('''
            IDDETALLE,
            IDVENTA,
            IDPRODUCTO,
            CANTIDAD,
            METODOPAGO,
            PRECIO_UNITARIO,
            SUBTOTAL,
            FCREACION,
            TPRODUCTO!TDETALLEVENTA_IDPRODUCTO_fkey (
              IDPRODUCTO,
              IDSUCURSAL,
              NOMBRE,
              DESCRIPCION,
              PRECIO,
              CATEGORIA,
              DISPONIBLE,
              ESTADO
            )
          ''');

      // Filtrar por IDs de venta usando OR
      PostgrestFilterBuilder filteredQuery = query;
      if (idsVentas.isNotEmpty) {
        filteredQuery =
            filteredQuery.or(idsVentas.map((id) => 'IDVENTA.eq.$id').join(','));
      } else {
        return [];
      }

      // Aplicar filtros de fecha si existen
      if (fechaDesde != null) {
        filteredQuery =
            filteredQuery.gte('FCREACION', fechaDesde.toIso8601String());
      }
      if (fechaHasta != null) {
        filteredQuery =
            filteredQuery.lte('FCREACION', fechaHasta.toIso8601String());
      }

      final result = await filteredQuery;

      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      _handleError(e, 'getDetallesConProductosByVentas');
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
