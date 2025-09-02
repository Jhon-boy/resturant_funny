import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/user_entity.dart';
import 'package:resturant_funny/shared/enums/endpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exception.dart';

class AuthRemoteDataSourceImpl {
  final HttpClient client;
  final WidgetRef ref;

  AuthRemoteDataSourceImpl({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);
  final SupabaseClient supabase = Supabase.instance.client;

  /// LOGIN con usuario y contraseña
  Future<UserEntity> login(String usuario, String password) async {
    try {
      final usuarioResponse = await supabase
          .from("TUSUARIO")
          .select("*")
          .eq("USUARIO", usuario)
          .maybeSingle();

      if (usuarioResponse == null) {
        throw ServerException(message: "Usuario no encontrado");
      }

      final hashedPassword = AppUtils.generateSha256(password);
      if (usuarioResponse['PASSWORD'] != hashedPassword) {
        throw ServerException(message: "Contraseña incorrecta");
      }
      final persona =
          await getPersonaByIdentificacion(usuarioResponse['IDENTIFICACION']);
      final user = UserEntity.fromJson(
        usuarioJson: usuarioResponse,
        personaJson: persona.toJson(),
      );

      return user;
    } catch (e) {
      debugPrint(e.toString());
      if (e is ServerException) rethrow;
      throw ServerException(message: "Error en login: ${e.toString()}");
    }
  }

  /// MÉTODO REUTILIZABLE PARA OBTENER DATOS DE PERSONA
  Future<PersonaEntity> getPersonaByIdentificacion(
      String identificacion) async {
    try {
      final response = await supabase
          .from("TPERSONA")
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
      final jsonResponse = json.decode(response.body);
      return null;
    } else {
      throw ServerException(message: 'Error checking auth status');
    }
  }
}
