// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:resturant_funny/core/errors/exception.dart';
import 'package:resturant_funny/core/services/enhanced_auth_service.dart';
import 'package:resturant_funny/shared/widgets/dialog_widget.dart';

class SessionHandler {
  /// Maneja excepciones de sesión y muestra alertas apropiadas
  static void handleSessionException(
    BuildContext context,
    dynamic error, {
    VoidCallback? onSessionExpired,
  }) {
    if (error is SessionException) {
      // Mostrar alerta de sesión expirada
      DialogHelper.error(
        context,
        title: 'Sesión Expirada',
        message: error.message,
        onConfirmed: () async {
          // Cerrar sesión
          await EnhancedAuthService.logout();

          // Ejecutar callback personalizado o redirigir al login
          if (onSessionExpired != null) {
            onSessionExpired();
          } else {
            // Redirigir al login por defecto
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
      );
    }
  }

  /// Wrapper para operaciones que requieren sesión válida
  static Future<T?> executeWithSessionCheck<T>(
    BuildContext context,
    Future<T> Function() operation, {
    VoidCallback? onSessionExpired,
  }) async {
    try {
      return await operation();
    } catch (error) {
      handleSessionException(context, error,
          onSessionExpired: onSessionExpired);
      return null;
    }
  }

  /// Verifica sesión antes de operaciones críticas
  static bool checkSessionBeforeOperation(BuildContext context) {
    if (!EnhancedAuthService.isLoggedIn) {
      DialogHelper.error(
        context,
        title: 'Sesión Requerida',
        message: 'Debe iniciar sesión para continuar',
        onConfirmed: () {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        },
      );
      return false;
    }
    return true;
  }

  /// Muestra alerta de sesión próxima a expirar
  static void showSessionExpiringAlert(BuildContext context) {
    DialogHelper.info(
      context,
      title: 'Sesión Próxima a Expirar',
      message: 'Su sesión expirará en breve. ¿Desea renovarla?',
      onConfirmed: () async {
        // Intentar renovar sesión
        final renewed = await EnhancedAuthService.refreshSession();
        if (!renewed) {
          DialogHelper.error(
            context,
            title: 'Error',
            message: 'No se pudo renovar la sesión. Será redirigido al login.',
            onConfirmed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          );
        }
      },
    );
  }
}
