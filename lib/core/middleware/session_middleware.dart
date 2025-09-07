// Middleware para verificar sesión automáticamente
import 'package:flutter/material.dart';
import 'package:resturant_funny/core/services/enhanced_auth_service.dart';
import 'package:resturant_funny/core/utils/session_handler.dart';

class SessionMiddleware {
  /// Verifica y mantiene una sesión válida
  static Future<bool> ensureValidSession(BuildContext context) async {
    if (!EnhancedAuthService.isLoggedIn) {
      SessionHandler.checkSessionBeforeOperation(context);
      return false;
    }

    // Verificar si la sesión está próxima a expirar (10 minutos antes)
    if (EnhancedAuthService.sessionExpiry != null &&
        EnhancedAuthService.sessionExpiry!
            .isBefore(DateTime.now().add(const Duration(minutes: 10)))) {
      // Mostrar alerta de sesión próxima a expirar
      SessionHandler.showSessionExpiringAlert(context);

      // Intentar renovar sesión
      return await EnhancedAuthService.refreshSession();
    }

    return true;
  }

  /// Verifica sesión antes de operaciones críticas
  static Future<bool> checkBeforeCriticalOperation(BuildContext context) async {
    return await ensureValidSession(context);
  }

  /// Verifica sesión antes de operaciones de base de datos
  static bool checkBeforeDatabaseOperation(BuildContext context) {
    if (!EnhancedAuthService.isLoggedIn) {
      SessionHandler.checkSessionBeforeOperation(context);
      return false;
    }
    return true;
  }
}
