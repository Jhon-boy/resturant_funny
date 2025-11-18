import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/notification/models/notification_model.dart';
import 'package:resturant_funny/modules/notification/providers/notification_provider.dart';

class NotificationService {
  static final _random = Random();

  /// Genera un ID único para la notificación
  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(9999).toString();
  }

  /// Muestra una notificación genérica configurable
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// NotificationService.show(
  ///   icon: Icons.info,
  ///   title: 'Nueva orden',
  ///   description: 'Tienes una nueva orden pendiente',
  ///   onTap: () {
  ///     Navigator.push(...);
  ///   },
  /// );
  /// ```
  static void show({
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
    WidgetRef? ref,
  }) {
    final notification = NotificationModel(
      id: _generateId(),
      icon: icon,
      title: title,
      description: description,
      onTap: onTap,
    );

    // Si se proporciona un ref, usarlo directamente
    if (ref != null) {
      ref.read(notificationProvider.notifier).addNotification(notification);
      return;
    }

    // Si no hay ref, intentar obtenerlo del navigatorKey
    try {
      final context = AppUtils.navigatorKey.currentContext;
      if (context != null) {
        final container = ProviderScope.containerOf(context);
        container
            .read(notificationProvider.notifier)
            .addNotification(notification);
      } else {
        debugPrint(
            'Error: No hay contexto disponible para agregar notificación');
      }
    } catch (e) {
      debugPrint('Error al agregar notificación: $e');
      debugPrint(
          'Nota: Pasa un WidgetRef o asegúrate de tener un contexto válido');
    }
  }

  /// Muestra una notificación usando un BuildContext
  /// Útil cuando tienes acceso al contexto pero no al ref
  static void showWithContext({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    VoidCallback? onTap,
  }) {
    final container = ProviderScope.containerOf(context);
    final notification = NotificationModel(
      id: _generateId(),
      icon: icon,
      title: title,
      description: description,
      onTap: onTap,
    );
    container.read(notificationProvider.notifier).addNotification(notification);
  }
}
