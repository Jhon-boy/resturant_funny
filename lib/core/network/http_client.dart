import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:resturant_funny/app/config/enviroment.dart';
import 'package:resturant_funny/providers/auth_provider.dart';
import 'package:logger/logger.dart';

// METODO PARA REALIZAR PETICIONES HTTP A CUALQUIER API
class HttpClient {
  final WidgetRef ref;
  final Logger _logger;

  HttpClient(this.ref)
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 80,
            colors: true,
            printEmojis: true,
          ),
        );

  /// Método genérico para cualquier petición HTTP
  /// [method]: GET, POST, PUT, DELETE, PATCH...
  /// [url]: URL completa
  /// [headers]: Headers opcionales
  /// [body]: Map<String, dynamic> opcional para POST/PUT/PATCH
  /// [showLoader]: si true, activa el loader global
  Future<http.Response> request({
    required String method,
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      ref.read(userProvider.notifier).setLoading(true);
    }

    try {
      // Convertir body a JSON si existe
      String? encodedBody;
      if (body != null) {
        encodedBody = jsonEncode(body);
        headers = {
          ...?headers,
          'Content-Type': 'application/json',
        };
      }

      // Log de la petición
      if (EnvironmentConfig.current.enableLogs) {
        _logger.i('HTTP REQUEST ➡ $method $url');
        if (headers != null) _logger.i('Headers: $headers');
        if (encodedBody != null) _logger.i('Body: $encodedBody');
      }

      // Ejecutar petición HTTP
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: headers);
          break;
        case 'POST':
          response = await http.post(Uri.parse(url),
              headers: headers, body: encodedBody);
          break;
        case 'PUT':
          response = await http.put(Uri.parse(url),
              headers: headers, body: encodedBody);
          break;
        case 'PATCH':
          response = await http.patch(Uri.parse(url),
              headers: headers, body: encodedBody);
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url),
              headers: headers, body: encodedBody);
          break;
        default:
          throw Exception('Método HTTP no soportado: $method');
      }

      // Log de la respuesta
      if (EnvironmentConfig.current.enableLogs) {
        _logger.i(
            'HTTP RESPONSE ⬅ [${response.statusCode}] ${response.body.length} bytes');
        _logger.d('Response body: ${response.body}');
      }

      return response;
    } catch (e, stackTrace) {
      if (EnvironmentConfig.current.enableLogs) {
        _logger.e('HTTP ERROR: $method $url', error: e, stackTrace: stackTrace);
      }
      rethrow;
    } finally {
      if (showLoader) {
        ref.read(userProvider.notifier).setLoading(false);
      }
    }
  }
}
