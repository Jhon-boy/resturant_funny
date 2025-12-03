// services/enhanced_auth_service.dart
import 'package:flutter/material.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/usuario_entity.dart';
import 'package:resturant_funny/shared/enums/entities.dart';
import 'package:resturant_funny/shared/enums/estados_persona.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EnhancedAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static String? _currentSessionToken;
  static DateTime? sessionExpiry;
  static UserModel? _currentUser;

  // Getters públicos
  static UserModel? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null && _isSessionValid();
  static String? get sessionToken => _currentSessionToken;

  /// LOGIN SEGURO - IMPLEMENTACIÓN MANUAL ( 
  static Future<Map<String, dynamic>> loginSecure(
      String usuario, String password) async {
    try {
      // Generar hash SHA256 de la contraseña
      final hashedPassword = AppUtils.generateSha256(password);

 
      final usuarioResponse = await _supabase
          .from(Entities.TUSUARIO.tableName)
          .select("*")
          .eq("USUARIO", usuario)
          .maybeSingle();

      if (usuarioResponse == null) {
        return {
          'success': false,
          'message': 'Usuario o contraseña incorrectos',
          'error_code': 'AUTH_001'
        };
      }

      // Verificar contraseña
      if (usuarioResponse['PASSWORD'] != hashedPassword) {
        return {
          'success': false,
          'message': 'Usuario o contraseña incorrectos',
          'error_code': 'AUTH_002'
        };
      }

      // Obtener datos de persona DIRECTAMENTE (sin validar sesión)
      final persona = await _getPersonaByIdentificacionDirect(
          usuarioResponse['IDENTIFICACION']);

      // Crear entidad de usuario
      _currentUser = UserModel.fromJson(
        usuarioJson: usuarioResponse,
        personaJson: persona.toJson(),
      );

      // Generar token de sesión simple
      _currentSessionToken = AppUtils.generateToken();
      sessionExpiry = AppUtils.generateTimeExpiration();

      // Guardar sesión localmente
      await _saveSession();

      return {
        'success': true,
        'user': _currentUser,
        'message': 'Login exitoso'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
        'error_code': 'CONN_001'
      };
    }
  }

  static Future<UserModel> login(String usuario, String password) async {
    final result = await loginSecure(usuario, password);

    if (result['success']) {
      return result['user'] as UserModel;
    } else {
      throw ServerException(message: result['message']);
    }
  }

  /// VALIDAR SESIÓN ACTUAL
  static Future<bool> validateCurrentSession() async {
    if (_currentSessionToken == null || _currentUser == null) return false;

    try {
      if (sessionExpiry != null && sessionExpiry!.isAfter(DateTime.now())) {
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  /// LOGOUT SEGURO
  static Future<void> logout() async {
    try {
      // Limpiar datos locales
      _currentUser = null;
      _currentSessionToken = null;
      sessionExpiry = null;

      // Limpiar almacenamiento local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session_token');
      await prefs.remove('user_session_expiry');
      await prefs.remove('current_user_data');

      // Limpiar headers
      _supabase.rest.headers.remove('Authorization');
    } catch (e) {
      debugPrint('Error durante logout: $e');
    }
  }

  /// VERIFICAR Y RESTAURAR SESIÓN AL INICIAR APP
  static Future<bool> initializeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_session_token');
      final expiryString = prefs.getString('user_session_expiry');
      final userDataString = prefs.getString('current_user_data');

      if (token != null && expiryString != null && userDataString != null) {
        final expiry = DateTime.parse(expiryString);

        // Verificar si la sesión no ha expirado
        if (expiry.isAfter(DateTime.now())) {
          _currentSessionToken = token;
          sessionExpiry = expiry;

          // Restaurar datos de usuario
          final userData = json.decode(userDataString);
          _currentUser = UserModel.fromJson(
            usuarioJson: userData['usuario'],
            personaJson: userData['persona'],
          );

          // Configurar header
          _supabase.rest.headers['Authorization'] = 'Bearer $token';

          // Validar sesión localmente
          return validateCurrentSession();
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error al inicializar sesión: $e');
      return false;
    }
  }

  /// OBTENER DATOS DE PERSONA DIRECTAMENTE (SIN VALIDAR SESIÓN - PARA LOGIN)
  static Future<PersonaEntity> _getPersonaByIdentificacionDirect(
      String identificacion) async {
    try {
      final response = await _supabase
          .from(Entities.TPERSONA.tableName)
          .select("*")
          .eq("IDENTIFICACION", identificacion)
          .maybeSingle();

      if (response == null) {
        throw ServerException(
          message: "No se encontraron datos de persona para $identificacion",
        );
      }

      final persona = PersonaEntity.fromJson(response);
      if (persona.estado == EstadosPersona.INACTIVO.state) {
        throw ServerException(
            message: "Inicio de sesión no permitido: Estado inactivo");
      }
      if (persona.estado == EstadosPersona.BLOQUEADO.state) {
        throw ServerException(
            message: "Inicio de sesión no permitido: Estado bloqueado");
      }
      if (persona.estado == EstadosPersona.SUSPENDIDO.state) {
        throw ServerException(
            message: "Inicio de sesión no permitido: Estado suspendido");
      }
      if (persona.estado == EstadosPersona.PENDIENTE.state) {
        throw ServerException(
            message: "Inicio de sesión no permitido: Estado pendiente");
      }
      return persona;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: "Error obteniendo datos de persona: ${e.toString()}");
    }
  }

  /// OBTENER DATOS DE PERSONA (CON SEGURIDAD RLS)
  static Future<PersonaEntity> getPersonaByIdentificacion(
      String identificacion) async {
    try {
      if (!isLoggedIn) {
        throw ServerException(
            message: "getPersonaByIdentificacion Sesión no válida");
      }
      debugPrint("identificacion: --> $identificacion");
      final response = await _supabase
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

  static Future<TUsuariEntity> getUserById(int idUsuario) async {
    try {
      if (!isLoggedIn) {
        throw ServerException(message: " getUserById Sesión no válida");
      }

      final response = await _supabase
          .from(Entities.TUSUARIO.tableName)
          .select("*")
          .eq("IDUSUARIO", idUsuario)
          .maybeSingle();

      if (response == null) {
        throw ServerException(
          message: "No se encontraron datos de persona para $idUsuario",
        );
      }

      return TUsuariEntity.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: "Error obteniendo datos de persona: ${e.toString()}");
    }
  }

  /// CAMBIAR CONTRASEÑA
  static Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    if (!isLoggedIn) {
      return {'success': false, 'message': 'No hay sesión activa'};
    }

    try {
      final newHash = AppUtils.generateSha256(newPassword);

      // Verificar login con contraseña actual
      final loginCheck =
          await loginSecure(_currentUser!.usuario!, currentPassword);

      if (!loginCheck['success']) {
        return {'success': false, 'message': 'Contraseña actual incorrecta'};
      }

      // Actualizar contraseña
      await _supabase
          .from(Entities.TUSUARIO.tableName)
          .update({'PASSWORD': newHash}).eq('USUARIO', _currentUser!.usuario!);

      return {
        'success': true,
        'message': 'Contraseña actualizada exitosamente'
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al cambiar contraseña: $e'};
    }
  }

  /// REFRESCAR SESIÓN
  static Future<bool> refreshSession() async {
    if (_currentUser != null) {
      // Intentar renovar la sesión con las credenciales actuales
      return await validateCurrentSession();
    }
    return false;
  }

  static bool _isSessionValid() {
    if (sessionExpiry == null) return false;
    return sessionExpiry!
        .isAfter(DateTime.now().add(const Duration(minutes: 5)));
  }

  static Future<void> _saveSession() async {
    if (_currentUser != null && _currentSessionToken != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('user_session_token', _currentSessionToken!);
      await prefs.setString(
          'user_session_expiry', sessionExpiry!.toIso8601String());

      // Guardar datos de usuario
      final userData = {
        'usuario': _currentUser!.toJson(),
        'persona': _currentUser!.toJson(),
      };
      await prefs.setString('current_user_data', json.encode(userData));
    }
  }

  /// Guardar sesión cuando el dispositivo es de confianza
  static Future<void> saveDeviceTrustSession({
    required UserModel user,
    required String sessionToken,
    required DateTime expiry,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_session_token', sessionToken);
    await prefs.setString('user_session_expiry', expiry.toIso8601String());

    // Guardar datos de usuario
    final userData = {
      'usuario': user.toJson(),
      'persona': user.toJson(),
    };
    await prefs.setString('current_user_data', json.encode(userData));

    // Actualizar variables estáticas
    _currentUser = user;
    _currentSessionToken = sessionToken;
    sessionExpiry = expiry;
  }
}
