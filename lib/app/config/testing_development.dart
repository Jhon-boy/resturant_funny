import 'package:resturant_funny/app/config/env_config.dart';
import 'package:resturant_funny/app/config/enviroment.dart';
import 'package:resturant_funny/shared/enums/enviroment.dart';

/// Configuración para ambiente de Testing/QA
class TestingEnvironment extends Environment {
  TestingEnvironment()
      : super(
          type: EnvironmentType.testing,
          apiBaseUrl: EnvConfig.API_URL,
          enableLogs: true,
          enableDebugMode: false,
        );
}
