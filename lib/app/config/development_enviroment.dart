import 'package:resturant_funny/app/config/env_config.dart';
import 'package:resturant_funny/app/config/enviroment.dart';
import 'package:resturant_funny/shared/enums/enviroment.dart';

/// Configuración para ambiente de Desarrollo
class DevelopmentEnvironment extends Environment {
  DevelopmentEnvironment()
      : super(
          type: EnvironmentType.development,
          apiBaseUrl: EnvConfig.API_URL,
          enableLogs: true,
          enableDebugMode: true,
        );
}
