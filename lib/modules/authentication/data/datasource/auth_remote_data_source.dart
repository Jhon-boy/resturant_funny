import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/models/deviceInfo_model.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/enhanced_auth_service.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/dispositivo_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/shared/enums/endpoints.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exception.dart';

class AuthRemoteDataSourceImpl {
  final HttpClient client;
  final WidgetRef ref;

  AuthRemoteDataSourceImpl({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);
  final SupabaseClient supabase = Supabase.instance.client;

  /// LOGIN con usuario y contraseña
  Future<UserModel> login(String usuario, String password) async {
    try {
      return await EnhancedAuthService.login(usuario, password);
    } catch (e) {
      debugPrint("Error en login: ${e.toString()}");
      if (e is ServerException) rethrow;
      throw ServerException(message: "Error en login: ${e.toString()}");
    }
  }

  /// MÉTODO REUTILIZABLE PARA OBTENER DATOS DE PERSONA
  Future<PersonaEntity> getPersonaByIdentificacion(
      String identificacion) async {
    try {
      final response = await supabase
          .from(Entities.TPERSONA.tableName)
          .select("*")
          .eq("IDENTIFICACION", identificacion)
          .maybeSingle();

      if (response == null) {
        throw ServerException(
          message: "No se encontraron datos de persona para $identificacion",
        );
      }

      return PersonaEntity.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: "Error obteniendo datos de persona: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    const endpoint = Endpoints.LOGOUT;
    final url = endpoint.getFullUrl('YOUR_BASE_API_URL');

    final response = await client.request(
      method: endpoint.getMethod,
      url: url,
    );

    if (response.statusCode != AppConstants.STATUS_OK) {
      throw ServerException(message: 'Error en el logout');
    }
  }

  Future<Null> checkAuthStatus() async {
    const endpoint = Endpoints.CHECK_AUTH;
    final url = endpoint.getFullUrl('YOUR_BASE_API_URL');

    final response = await client.request(
      method: endpoint.getMethod,
      url: url,
    );

    if (response.statusCode == AppConstants.STATUS_OK) {
      json.decode(response.body);
      return null;
    } else {
      throw ServerException(message: 'Error checking auth status');
    }
  }

  /// Verifica si un dispositivo es de confianza
  Future<UserModel?> isTrustedDevice(DeviceInfoModel deviceInfo) async {
    try {
      debugPrint('isTrustedDevice: ${deviceInfo.toJson()}');
      final deviceRecord = await SupabaseService.selectSingleFree(
        table: Entities.TDISPOSITIVO.tableName,
        filters: {
          'IMEI': deviceInfo.idUnico,
        },
      );

      if (deviceRecord == null) return null;
      if (!_verifyDeviceData(deviceInfo, deviceRecord)) return null;
      final userId = deviceRecord['IDUSUARIO'] as int;
      final user = await _buildUserModel(userId);
      await EnhancedAuthService.saveDeviceTrustSession(
        user: user,
        sessionToken: AppUtils.generateToken(),
        expiry: AppUtils.generateTimeExpiration(),
      );
      return user;
    } catch (e) {
      debugPrint("Error verificando dispositivo: ${e.toString()}");
      return null;
    }
  }

  /// Verifica si un dispositivo es de confianza
  Future<DispositivoEntity?> getDeviceByIdDispositivo(
      String imei) async {
    try {
      final deviceRecord = await SupabaseService.selectSingleFree(
        table: Entities.TDISPOSITIVO.tableName,
        filters: {
          'IMEI': imei,
        },
      );

      if (deviceRecord == null) return null;
      return DispositivoEntity.fromJson(deviceRecord);
    } catch (e) {
      debugPrint("Error verificando dispositivo: ${e.toString()}");
      return null;
    }
  }

// Obtiene la informacion del usuario a travez del IDUSUARIO
  Future<UserModel> _buildUserModel(int userId) async {
    final userRecord = await SupabaseService.selectSingleFree(
      table: Entities.TUSUARIO.tableName,
      filters: {'IDUSUARIO': userId},
    );

    if (userRecord == null) {
      throw ServerException(
        message: "No se encontraron datos de usuario para $userId",
      );
    }

    final personaRecord = await SupabaseService.selectSingleFree(
      table: Entities.TPERSONA.tableName,
      filters: {'IDENTIFICACION': userRecord['IDENTIFICACION']},
    );

    if (personaRecord == null) {
      throw ServerException(
        message:
            "No se encontraron datos de persona para ${userRecord['IDENTIFICACION']}",
      );
    }

    return UserModel.fromJson(
      usuarioJson: userRecord,
      personaJson: personaRecord,
    );
  }

  /// Verifica si el dispositivo actual es de confianza
  Future<bool> isCurrentDeviceTrusted() async {
    try {
      final deviceInfo = await AppUtils.getInfoDevice();
      final UserModel = await isTrustedDevice(deviceInfo);

      return UserModel != null;
    } catch (e) {
      debugPrint(
          "Error obteniendo información del dispositivo: ${e.toString()}");
      return false;
    }
  }

  /// Registra un dispositivo como de confianza
  /// Recibe el UserModel y el DeviceInfoModel para vincular correctamente el dispositivo con el usuario
  Future<bool> registerTrustedDevice(
      UserModel entity, DeviceInfoModel deviceInfo) async {
    try {
      debugPrint('registerTrustedDevice: ${deviceInfo.toJson()}');
      // Validar que el dispositivo tenga un IMEI válido
      if (deviceInfo.idUnico == null || deviceInfo.idUnico!.isEmpty) {
        debugPrint('ERROR: El dispositivo no tiene un IMEI válido');
        return false;
      }

      // Verificar si ya existe un dispositivo con este IMEI
      final existingDevice = await SupabaseService.selectSingle(
        table: Entities.TDISPOSITIVO.tableName,
        filters: {
          'IMEI': deviceInfo.idUnico,
        },
      );

      if (existingDevice != null) {
        // Si el dispositivo ya existe y pertenece a otro usuario, no permitir el registro
        final existingUserId = existingDevice['IDUSUARIO'] as int;
        if (existingUserId != entity.idUsuario) {
          debugPrint(
              'ERROR: El dispositivo ya está registrado por otro usuario');
          return false;
        }

        // Si pertenece al mismo usuario, actualizar último acceso
        await SupabaseService.update(
          table: Entities.TDISPOSITIVO.tableName,
          data: {
            'ULTIMOACCESO': AppUtils.getFechaActual().toIso8601String(),
            'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
            'USERMODIFICACION': entity.usuario ?? '',
          },
          filters: {
            'IMEI': deviceInfo.idUnico,
          },
        );
        debugPrint('Dispositivo actualizado exitosamente');
        return true;
      }

      // Registrar nuevo dispositivo con el IMEI del dispositivo actual
      await SupabaseService.insert(
        table: Entities.TDISPOSITIVO.tableName,
        data: {
          'IDUSUARIO': entity.idUsuario,
          'IMEI': deviceInfo.idUnico, // IMEI del dispositivo actual
          'MARCA': deviceInfo.fabricante ?? 'Desconocida',
          'MODELO': deviceInfo.modelo ?? 'Desconocido',
          'SISTEMAOPERATIVO': deviceInfo.sistemaOperativo ?? 'Desconocido',
          'ULTIMOACCESO': AppUtils.getFechaActual().toIso8601String(),
          'FCREACION': AppUtils.getFechaActual().toIso8601String(),
          'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
          'USUARIOINGRESO': entity.usuario ?? '',
          'USERMODIFICACION': entity.usuario ?? '',
        },
      );

      debugPrint(
          'Dispositivo registrado exitosamente con IMEI: ${deviceInfo.idUnico}');
      return true;
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS al registrar dispositivo: $e');
      return false;
    }
  }

  /// Elimina un dispositivo de confianza
  Future<bool> removeTrustedDevice(String imei) async {
    try {
      await SupabaseService.delete(
        table: Entities.TDISPOSITIVO.tableName,
        filters: {
          'IMEI': imei,
        },
      );
      return true;
    } catch (e) {
      debugPrint("Error eliminando dispositivo: ${e.toString()}");
      return false;
    }
  }

  /// Verifica si los datos del dispositivo coinciden con los registrados
  bool _verifyDeviceData(
      DeviceInfoModel currentDevice, Map<String, dynamic> registeredDevice) {
    if (currentDevice.fabricante?.toLowerCase() !=
        registeredDevice['MARCA']?.toString().toLowerCase()) {
      return false;
    }

    if (currentDevice.modelo?.toLowerCase() !=
        registeredDevice['MODELO']?.toString().toLowerCase()) {
      return false;
    }

    if (currentDevice.sistemaOperativo?.toLowerCase() !=
        registeredDevice['SISTEMAOPERATIVO']?.toString().toLowerCase()) {
      return false;
    }

    return true;
  }

  Future<List<RolEntity>> getRolesUsuario(int idUsuario) async {
    try {
      // Obtenemos los roles del usuario haciendo join
      final List<Map<String, dynamic>> records = await SupabaseService.select(
        table: Entities.TROLUSUARIO.tableName,
        columns:
            'TROL(IDROL, CODIGO, NOMBRE, FCREACION, FMODIFICACION, OBSERVACION, ESTADO, USUARIOINGRESO, USERMODIFICACION)',
        filters: {'IDUSUARIO': idUsuario},
      );

      final roles = records.map((r) {
        final rolData = r[Entities.TROL.tableName] as Map<String, dynamic>;
        return RolEntity.fromJson(rolData);
      }).toList();

      return roles;
    } catch (e) {
      debugPrint("Error obteniendo roles del usuario: ${e.toString()}");
      return [];
    }
  }
}
