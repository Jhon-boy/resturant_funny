import 'dart:convert';

import 'package:resturant_funny/core/network/http_client.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/user_entity.dart';
import 'package:resturant_funny/shared/enums/endpoints.dart';
import '../../../../core/errors/exception.dart';

class AuthRemoteDataSourceImpl {
  final HttpClient client;

  AuthRemoteDataSourceImpl({required this.client});

  Future<UserEntity> login(String email, String password) async {
    const endpoint = Endpoints.LOGIN;
    final url = endpoint.getFullUrl('YOUR_BASE_API_URL');

    final response = await client.request(
      method: endpoint.getMethod,
      url: url,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final user = UserEntity.fromJson(jsonResponse['user']);
      return user;
    } else {
      throw ServerException(message: 'Error en el login');
    }
  }
}
