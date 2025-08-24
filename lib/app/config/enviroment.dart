import 'dart:developer' as developer;
import 'package:resturant_funny/app/config/development_enviroment.dart';
import 'package:resturant_funny/app/config/production_enviroment.dart';
import 'package:resturant_funny/app/config/testing_development.dart';
import 'package:resturant_funny/shared/enums/enviroment.dart';

/// Clase base para configuración de ambiente
class Environment {
  final EnvironmentType type;
  final String apiBaseUrl;
  final bool enableLogs;
  final bool enableDebugMode;

  const Environment({
    required this.type,
    required this.apiBaseUrl,
    required this.enableLogs,
    required this.enableDebugMode,
  });

  /// Método para imprimir logs solo si están habilitados
  void log(String message, {String? tag}) {
    if (enableLogs) {
      // ignore: unnecessary_string_interpolations
      final logTag = tag ?? '${type.name.toUpperCase()}';
      developer.log(message, name: logTag);
    }
  }
}

/// Clase principal para manejar la configuración del ambiente
class EnvironmentConfig {
  static Environment? _currentEnvironment;

  /// Inicializar el ambiente
  static void initialize(EnvironmentType type) {
    switch (type) {
      case EnvironmentType.development:
        _currentEnvironment = DevelopmentEnvironment();
        break;
      case EnvironmentType.testing:
        _currentEnvironment = TestingEnvironment();
        break;
      case EnvironmentType.production:
        _currentEnvironment = ProductionEnvironment();
        break;
    }

    _currentEnvironment?.log('Ambiente inicializado: ${type.name}');
  }

  /// Obtener el ambiente actual
  static Environment get current {
    if (_currentEnvironment == null) {
      throw StateError(
          'Environment not initialized. Call EnvironmentConfig.initialize() first.');
    }
    return _currentEnvironment!;
  }

  /// Verificar si es desarrollo
  static bool get isDevelopment => current.type == EnvironmentType.development;

  /// Verificar si es testing
  static bool get isTesting => current.type == EnvironmentType.testing;

  /// Verificar si es producción
  static bool get isProduction => current.type == EnvironmentType.production;
}
