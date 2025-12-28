import 'dart:convert';
import 'package:balansoved_mobile/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    super.title,
    super.body,
    super.icon,
    required super.createdAt,
    required super.isDelivered,
    required super.isArchived,
    super.additionalInfo,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? addInfo;
    final raw = json['additional_info_json'];
    if (raw is Map<String, dynamic>) {
      addInfo = raw;
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          addInfo = decoded;
        }
      } catch (_) {
        // ignore parse error, keep null
      }
    }

    return NotificationModel(
      id: json['notice_id'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      isDelivered: json['is_delivered'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      additionalInfo: addInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notice_id': id,
      'title': title,
      'body': body,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'is_delivered': isDelivered,
      'is_archived': isArchived,
      if (additionalInfo != null) 'additional_info_json': additionalInfo,
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      icon: icon,
      createdAt: createdAt,
      isDelivered: isDelivered,
      isArchived: isArchived,
      additionalInfo: additionalInfo,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      icon: entity.icon,
      createdAt: entity.createdAt,
      isDelivered: entity.isDelivered,
      isArchived: entity.isArchived,
      additionalInfo: entity.additionalInfo,
    );
  }
}
