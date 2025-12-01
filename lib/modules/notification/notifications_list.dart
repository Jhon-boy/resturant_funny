import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/modules/notification/models/notification_model.dart';
import 'package:resturant_funny/modules/notification/providers/notification_provider.dart';

class NotificationsList extends ConsumerStatefulWidget {
  const NotificationsList({super.key});

  @override
  ConsumerState<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends ConsumerState<NotificationsList> {
  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final unreadCount = notificationState.unreadCount;

    return Scaffold(
      backgroundColor: ThemeApp.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeApp.primary,
        foregroundColor: ThemeApp.baseText,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontFamily: ThemeApp.fontFamily,
            color: ThemeApp.baseText,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text(
                'Marcar todas como leídas',
                style: TextStyle(
                  color: ThemeApp.baseText,
                  fontFamily: ThemeApp.fontFamily,
                ),
              ),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: ThemeApp.inputBorder,
          ),
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: ThemeApp.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeApp.textSecondary,
              fontFamily: ThemeApp.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Las notificaciones aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: ThemeApp.textSecondary,
              fontFamily: ThemeApp.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final timeAgo = _getTimeAgo(notification.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: notification.isRead ? ThemeApp.cardColors : ThemeApp.inputBorder,
      child: InkWell(
        onTap: () {
          // Marcar como leída si no lo está
          if (!notification.isRead) {
            ref.read(notificationProvider.notifier).markAsRead(notification.id);
          }

          // Ejecutar acción si existe
          if (notification.onTap != null) {
            notification.onTap!();
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ThemeApp.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: ThemeApp.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: ThemeApp.textPrimary,
                              fontFamily: ThemeApp.fontFamily,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: ThemeApp.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ThemeApp.textSecondary,
                        fontFamily: ThemeApp.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeApp.textSecondary.withOpacity(0.7),
                        fontFamily: ThemeApp.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón eliminar
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 20,
                  color: ThemeApp.textSecondary,
                ),
                onPressed: () {
                  ref
                      .read(notificationProvider.notifier)
                      .removeNotification(notification.id);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      return '$day/$month/$year';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }
}
