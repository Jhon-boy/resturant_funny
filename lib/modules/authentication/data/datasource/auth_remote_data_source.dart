import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/models/deviceInfo_model.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/services/enhanced_auth_service.dart';
import 'package:resturant_funny/core/services/supabase_service.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
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

// Obtiene la informacion del usuario a travez del IDUSUARIO
  Future<UserModel> _buildUserModel(int userId) async {
    final userInfo = await EnhancedAuthService.getUserById(userId);
    final personaInfo = await EnhancedAuthService.getPersonaByIdentificacion(
        userInfo.identificacion);
    return UserModel.fromJson(
      usuarioJson: userInfo.toJson(),
      personaJson: personaInfo.toJson(),
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
  Future<bool> registerTrustedDevice(UserModel entity) async {
    try {
      final deviceInfo = await AppUtils.getInfoDevice();

      // Verificar si ya existe
      final existingDevice = await SupabaseService.selectSingle(
        table: Entities.TDISPOSITIVO.tableName,
        filters: {
          'IMEI': deviceInfo.idUnico,
        },
      );

      if (existingDevice != null) {
        // Actualizar último acceso
        await SupabaseService.update(
          table: Entities.TDISPOSITIVO.tableName,
          data: {
            'ULTIMOACCESO': AppUtils.getFechaActual().toIso8601String(),
            'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
          },
          filters: {
            'IMEI': deviceInfo.idUnico,
          },
        );
        return true;
      }

      // Registrar nuevo dispositivo
      await SupabaseService.insert(
        table: Entities.TDISPOSITIVO.tableName,
        data: {
          'IDUSUARIO': entity.idUsuario,
          'IMEI': deviceInfo.idUnico,
          'MARCA': deviceInfo.fabricante ?? 'Desconocida',
          'MODELO': deviceInfo.modelo ?? 'Desconocido',
          'SISTEMAOPERATIVO': deviceInfo.sistemaOperativo ?? 'Desconocido',
          'ULTIMOACCESO': AppUtils.getFechaActual().toIso8601String(),
          'FCREACION': AppUtils.getFechaActual().toIso8601String(), 
          'USUARIOINGRESO': entity.usuario,
          'USERMODIFICACION': '',
        },
      );

      return true;
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS: $e');
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
