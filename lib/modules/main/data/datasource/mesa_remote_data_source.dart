import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/main/domain/entity/mesa_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MesasRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  MesasRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<MesaEntity>> getMesas(int idSucursal) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TMESA.tableName,
        filters: {'IDSUCURSAL': idSucursal},
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => MesaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getMesas');
    }
  }

  Future<MesaEntity?> getMesaById(String idMesa) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TMESA.tableName,
        filters: {'IDMESA': int.parse(idMesa)},
      );
      if (result == null) return null;
      return MesaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getMesaById');
    }
  }

  Future<MesaEntity> createMesa(MesaEntity mesa, UserModel? user) async {
    try {
      final data = mesa.toJson();
      // No incluir IDMESA en el INSERT ya que es GENERATED ALWAYS AS IDENTITY
      data.remove('IDMESA');
      if (user != null) data['USUARIOINGRESO'] = user.idUsuario;
      final result = await SupabaseService.insert(
        table: Entities.TMESA.tableName,
        data: data,
      );
      return MesaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createMesa');
    }
  }

  Future<MesaEntity> updateMesaById(
      String idMesa, Map<String, dynamic>? data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TMESA.tableName,
        data: data ?? {},
        filters: {'IDMESA': int.parse(idMesa)},
        returnData: true,
      );
      return MesaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateMesaById');
    }
  }

  Future<List<MesaEntity>> updateMesas(
      List<MesaEntity>? mesas, UserModel? user) async {
    try {
      final updated = <MesaEntity>[];
      if (mesas == null) return updated;

      for (final mesa in mesas) {
        final data = mesa.toJson();
        if (user != null) data['USUARIOMODIFICA'] = user.idUsuario;

        final result = await SupabaseService.update(
          table: Entities.TMESA.tableName,
          data: data,
          filters: {'IDMESA': mesa.idMesa},
        );

        updated.addAll(result.map((json) => MesaEntity.fromJson(json)));
      }
      return updated;
    } catch (e) {
      _handleError(e, 'updateMesas');
    }
  }

  Future<bool> deleteMesa(String idMesa, UserModel? user) async {
    try {
      final data = {
        'ESTADO': EstadosPersona.INACTIVO.state,
        'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
        'USERMODIFICACION': user?.idUsuario?.toString(),
      };

      await SupabaseService.update(
        table: Entities.TMESA.tableName,
        data: data,
        filters: {'IDMESA': int.parse(idMesa)},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteMesa');
    }
  }

  Future<List<MesaEntity>> searchMesas({
    String? nombre,
    int? capacidadMin,
    int? capacidadMax,
    bool? disponible,
  }) async {
    try {
      final allMesas = await SupabaseService.select(
        table: Entities.TMESA.tableName,
      );

      var filtered = allMesas;
      if (nombre != null && nombre.isNotEmpty) {
        filtered = filtered
            .where((m) => (m['NOMBRE'] as String)
                .toLowerCase()
                .contains(nombre.toLowerCase()))
            .toList();
      }
      if (capacidadMin != null) {
        filtered = filtered
            .where((m) => (m['CAPACIDAD'] as num).toInt() >= capacidadMin)
            .toList();
      }
      if (capacidadMax != null) {
        filtered = filtered
            .where((m) => (m['CAPACIDAD'] as num).toInt() <= capacidadMax)
            .toList();
      }
      if (disponible != null) {
        filtered =
            filtered.where((m) => m['DISPONIBLE'] == disponible).toList();
      }

      return filtered.map((json) => MesaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'searchMesas');
    }
  }

  Future<MesaEntity> toggleDisponibilidad(
      String idMesa, bool? disponible) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TMESA.tableName,
        data: {'DISPONIBLE': disponible ?? true},
        filters: {'IDMESA': int.parse(idMesa)},
      );
      return MesaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleDisponibilidad');
    }
  }

  Future<int> countMesas({int? idSucursal}) async {
    try {
      final result = await SupabaseService.count(
        table: Entities.TMESA.tableName,
        filters: idSucursal != null ? {'IDSUCURSAL': idSucursal} : null,
      );
      return result;
    } catch (e) {
      _handleError(e, 'countMesas');
    }
  }

  Future<dynamic> ejecutarFuncionRemota(
      String functionName, Map<String, dynamic>? params) async {
    try {
      return await SupabaseService.rpc(
        functionName: functionName,
        params: params,
      );
    } catch (e) {
      _handleError(e, 'ejecutarFuncionRemota');
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
