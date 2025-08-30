// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';

class EnvConfig {
  // ignore: prefer_final_fields
  static Map<String, String> _envVars = {};
  static bool _loaded = false;

  /// Cargar variables desde archivo .env
  static Future<void> load() async {
    if (_loaded) return;

    try {
      final file = File('.env');
      if (await file.exists()) {
        final lines = await file.readAsLines();

        for (final line in lines) {
          if (line.trim().isNotEmpty && !line.startsWith('#')) {
            final parts = line.split('=');
            if (parts.length == 2) {
              final key = parts[0].trim();
              final value = parts[1].trim();
              _envVars[key] = value;
            }
          }
        }
      }
      _loaded = true;
    } catch (e) {
      debugPrint('Error cargando archivo .env: $e');
    }
  }

  /// Variables de entorno expuestas como propiedades
  static String get API_URL => _envVars['API_BASE_URL'] ?? '';
  static int get API_TIMEOUT =>
      int.tryParse(_envVars['API_TIMEOUT'] ?? '30000') ?? 30000;

  /// AMBIENTES
  static String get ENVIRONMENT => _envVars['ENVIRONMENT'] ?? 'development';

  /// Variables de Supabase
  static String get SUPABASE_URL => _envVars['SUPABASE_URL'] ?? '';
  static String get SUPABASE_ANON_KEY => _envVars['SUPABASE_ANON_KEY'] ?? '';
}
