import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/modules/notification/models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;

  NotificationState({List<NotificationModel>? notifications})
      : notifications = notifications ?? [];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  NotificationState copyWith({
    List<NotificationModel>? notifications,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState());

  void addNotification(NotificationModel notification) {
    final updatedNotifications = [notification, ...state.notifications];
    state = state.copyWith(notifications: updatedNotifications);
  }

  void markAsRead(String notificationId) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    state = state.copyWith(notifications: updatedNotifications);
  }

  void markAllAsRead() {
    final updatedNotifications = state.notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updatedNotifications);
  }

  void removeNotification(String notificationId) {
    final updatedNotifications =
        state.notifications.where((n) => n.id != notificationId).toList();
    state = state.copyWith(notifications: updatedNotifications);
  }

  void clearAll() {
    state = NotificationState();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
