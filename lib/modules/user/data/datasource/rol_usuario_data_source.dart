import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/modules/user/domain/entity/rol_usuario_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';
import 'package:resturant_funny/shared/enums/roles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RolUsuarioRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  RolUsuarioRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  Future<TUsuariEntity?> getUsuarioById(int idUsuario) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TUSUARIO.tableName,
        filters: {'IDUSUARIO': idUsuario},
      );
      if (result == null) return null;
      return TUsuariEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getUsuarioById');
    }
  }

  /// Obtener IDROL por código desde TROL
  Future<int?> getIdRolByCodigo(String codigo) async {
    try {
      final rol = await SupabaseService.selectSingle(
        table: Entities.TROL.tableName,
        filters: {'CODIGO': codigo, 'ESTADO': EstadosPersona.ACTIVO.state},
      );
      if (rol == null) return null;
      return rol['IDROL'] as int?;
    } catch (e) {
      _handleError(e, 'getIdRolByCodigo');
    }
  }

  /// Obtener usuarios por rol usando código
  Future<List<TUsuariEntity>> getUsuariosByRol(String codigo) async {
    try {
      // Primero obtener IDROL desde TROL usando el código
      final idRol = await getIdRolByCodigo(codigo);
      if (idRol == null) {
        return [];
      }

      // Luego obtenemos los IDUSUARIO que tienen ese rol
      final rolUsuarios = await SupabaseService.select(
          table: Entities.TROLUSUARIO.tableName,
          columns: 'IDUSUARIO',
          filters: {'IDROL': idRol});

      if (rolUsuarios.isEmpty) {
        return [];
      }

      // Extraemos los IDs únicos
      final idsUsuarios =
          rolUsuarios.map((e) => e['IDUSUARIO'] as int).toSet().toList();

      // Obtenemos los usuarios con esos IDs
      final usuarios = <TUsuariEntity>[];
      for (final idUsuario in idsUsuarios) {
        final usuario = await getUsuarioById(idUsuario);
        if (usuario != null) {
          usuarios.add(usuario);
        }
      }

      return usuarios;
    } catch (e) {
      _handleError(e, 'getUsuariosByRol');
    }
  }

  /// Agregar rol a un usuario
  Future<bool> agregarRolUsuario(int idUsuario, int idRol) async {
    try {
      // Verificar si ya existe
      final existente = await SupabaseService.selectSingle(
        table: Entities.TROLUSUARIO.tableName,
        filters: {'IDUSUARIO': idUsuario, 'IDROL': idRol},
      );

      if (existente != null) {
        // Si existe pero está inactivo, reactivarlo
        await SupabaseService.update(
          table: Entities.TROLUSUARIO.tableName,
          data: {
            'ESTADO': EstadosPersona.ACTIVO.state,
            'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
          },
          filters: {
            'IDUSUARIO': idUsuario,
            'IDROL': idRol,
          },
          returnData: false,
        );
        return true;
      }

      // Crear nuevo registro
      await SupabaseService.insert(
        table: Entities.TROLUSUARIO.tableName,
        data: {
          'IDUSUARIO': idUsuario,
          'IDROL': idRol,
          'ESTADO': EstadosPersona.ACTIVO.state,
          'FCREACION': AppUtils.getFechaActual().toIso8601String()
        },
      );
      return true;
    } catch (e) {
      _handleError(e, 'agregarRolUsuario');
    }
  }

  /// Quitar rol de un usuario usando código
  Future<bool> quitarRolUsuario(int idUsuario, String codigo) async {
    try {
      // Primero obtener IDROL desde TROL usando el código
      final idRol = await getIdRolByCodigo(codigo);
      if (idRol == null) {
        throw DatabaseException('Rol con código $codigo no encontrado');
      }

      // Actualizar estado a INACTIVO en lugar de eliminar
      await SupabaseService.update(
        table: Entities.TROLUSUARIO.tableName,
        data: {
          'ESTADO': EstadosPersona.INACTIVO.state,
          'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
        },
        filters: {
          'IDUSUARIO': idUsuario,
          'IDROL': idRol,
        },
        returnData: false,
      );
      return true;
    } catch (e) {
      _handleError(e, 'quitarRolUsuario');
    }
  }

  /// Quitar rol de un usuario usando IDROL directamente
  Future<bool> quitarRolUsuarioByIdRol(int idUsuario, int idRol) async {
    try {
      // Actualizar estado a INACTIVO en lugar de eliminar
      await SupabaseService.update(
        table: Entities.TROLUSUARIO.tableName,
        data: {
          'ESTADO': EstadosPersona.INACTIVO.state,
          'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
        },
        filters: {
          'IDUSUARIO': idUsuario,
          'IDROL': idRol,
        },
        returnData: false,
      );
      return true;
    } catch (e) {
      _handleError(e, 'quitarRolUsuarioByIdRol');
    }
  }

  /// Obtener roles de un usuario
  Future<List<int>> getRolesUsuario(int idUsuario) async {
    try {
      final roles = await SupabaseService.select(
        table: Entities.TROLUSUARIO.tableName,
        columns: 'IDROL',
        filters: {
          'IDUSUARIO': idUsuario,
          'ESTADO': EstadosPersona.ACTIVO.state
        },
      );
      return roles.map((e) => e['IDROL'] as int?).whereType<int>().toList();
    } catch (e) {
      _handleError(e, 'getRolesUsuario');
    }
  }

  /// Obtener todos los registros de RolUsuario por IDUsuario
  Future<List<RolUsuarioEntity>> getRolUsuarioByUsuario(int idUsuario) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TROLUSUARIO.tableName,
        filters: {'IDUSUARIO': idUsuario},
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => RolUsuarioEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getRolUsuarioByUsuario');
    }
  }

  /// Obtener todos los roles activos de la aplicación
  Future<List<RolEntity>> getRoles() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TROL.tableName,
        filters: {'ESTADO': EstadosPersona.ACTIVO.state},
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => RolEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getRoles');
    }
  }


  Future<List<TUsuariEntity>> getUsuariosSinRolCliente() async {
    try {
      final idRolCliente = await getIdRolByCodigo(Rol.CLIENTE.code);

      final rolUsuarios = idRolCliente != null
          ? await SupabaseService.select(
              table: Entities.TROLUSUARIO.tableName,
              columns: 'IDUSUARIO',
              filters: {
                'IDROL_neq': idRolCliente,
              },
            )
          : await SupabaseService.select(
              table: Entities.TROLUSUARIO.tableName,
              columns: 'IDUSUARIO',
              filters: {'ESTADO': EstadosPersona.ACTIVO.state},
            );

      if (rolUsuarios.isEmpty) {
        return [];
      }

      final idsUsuarios = rolUsuarios
          .map((e) => e['IDUSUARIO'] as int?)
          .whereType<int>()
          .toSet()
          .toList();

      final usuarios = <TUsuariEntity>[];
      for (final idUsuario in idsUsuarios) {
        final usuario = await getUsuarioById(idUsuario);
        if (usuario != null) {
          usuarios.add(usuario);
        }
      }

      return usuarios;
    } catch (e) {
      _handleError(e, 'getUsuariosSinRolCliente');
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
