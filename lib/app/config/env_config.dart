// ignore_for_file: non_constant_identifier_names

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static bool _loaded = false;

  /// Cargar variables desde archivo .env
  static Future<void> load() async {
    if (_loaded) return;
    await dotenv.load(fileName: ".env");
    _loaded = true;
  }

  /// Variables de entorno expuestas como propiedades
  static String get API_URL => dotenv.env['API_BASE_URL'] ?? '';
  static int get API_TIMEOUT =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  /// AMBIENTES
  static String get ENVIRONMENT => dotenv.env['ENVIRONMENT'] ?? 'development';

  /// Variables de Supabase
  static String get SUPABASE_URL => dotenv.env['SUPABASE_URL'] ?? '';
  static String get SUPABASE_ANON_KEY => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
