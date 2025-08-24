import 'package:resturant_funny/app/config/env_config.dart';
import 'package:resturant_funny/app/config/enviroment.dart';
import 'package:resturant_funny/shared/enums/enviroment.dart';

/// Configuración para ambiente de Producción
class ProductionEnvironment extends Environment {
  ProductionEnvironment()
      : super(
            type: EnvironmentType.production,
            apiBaseUrl: EnvConfig.API_URL,
            enableLogs: false,
            enableDebugMode: false,
            timeOut: EnvConfig.API_TIMEOUT);
}
