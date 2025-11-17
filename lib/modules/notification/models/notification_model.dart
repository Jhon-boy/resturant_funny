import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  NotificationModel copyWith({
    String? id,
    IconData? icon,
    String? title,
    String? description,
    VoidCallback? onTap,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      onTap: onTap ?? this.onTap,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon.codePoint,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
