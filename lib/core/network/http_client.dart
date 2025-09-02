  import 'dart:convert';

  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:http/http.dart' as http;
  import 'package:resturant_funny/app/config/enviroment.dart';
  import 'package:resturant_funny/app/providers/provider.dart';
  import 'package:logger/logger.dart';
  import 'package:resturant_funny/core/errors/exception.dart';
  import 'package:resturant_funny/core/services/conection_service.dart';

  // METODO PARA REALIZAR PETICIONES HTTP A CUALQUIER API
  class HttpClient {
    final WidgetRef ref;
    final Logger _logger;
    final ConnectivityService _connectivity = ConnectivityService();

    HttpClient(this.ref)
        : _logger = Logger(
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 5,
              lineLength: 80,
              colors: true,
              printEmojis: false,
            ),
          ) {
      _connectivity.initialize();
    }

    Future<http.Response> request({
      required String method,
      required String url,
      Map<String, String>? headers,
      Map<String, dynamic>? body,
      bool showLoader = true,
    }) async {
      final isConnected = await _connectivity.checkConnection();
      if (!isConnected) {
        throw NetworkException(message: 'No internet connection');
      }

      if (showLoader) {
        ref.read(appStateProvider.notifier).setLoading(true);
      }

      try {
        String? encodedBody;
        if (body != null) {
          encodedBody = jsonEncode(body);
          headers = {
            ...?headers,
            'Content-Type': 'application/json',
          };
        }

        if (EnvironmentConfig.current.enableLogs) {
          _logger.i('HTTP REQUEST ➡ $method $url');
          if (headers != null) _logger.i('Headers: $headers');
          if (encodedBody != null) _logger.i('Body: $encodedBody');
        }

        final timeoutDuration = EnvironmentConfig.current.timeOut;
        late http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await http
                .get(Uri.parse(url), headers: headers)
                .timeout(Duration(seconds: timeoutDuration));
            break;
          case 'POST':
            response = await http
                .post(Uri.parse(url), headers: headers, body: encodedBody)
                .timeout(Duration(seconds: timeoutDuration));
            break;
          case 'PUT':
            response = await http
                .put(Uri.parse(url), headers: headers, body: encodedBody)
                .timeout(Duration(seconds: timeoutDuration));
            break;
          case 'PATCH':
            response = await http
                .patch(Uri.parse(url), headers: headers, body: encodedBody)
                .timeout(Duration(seconds: timeoutDuration));
            break;
          case 'DELETE':
            response = await http
                .delete(Uri.parse(url), headers: headers, body: encodedBody)
                .timeout(Duration(seconds: timeoutDuration));
            break;
          default:
            throw Exception('Método HTTP no soportado: $method');
        }

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
          ref.read(appStateProvider.notifier).setLoading(false);
        }
      }
    }
  }
