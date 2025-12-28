import 'dart:convert';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.clientIds,
    required super.assigneeIds,
    required super.observerIds,
    required super.creatorIds,
    required super.status,
    required super.priority,
    super.dueDate,
    super.completedAt,
    required super.attachments,
    required super.checklist,
    required super.reminders,
    super.recurrence,
    required super.options,
    super.holidayTransferRule,
    super.originTaskId,
    required super.createdAt,
    required super.updatedAt,
    super.relativeDates,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['task_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      clientIds: _parseStringList(json['client_ids_json']),
      assigneeIds: _parseStringList(json['assignee_ids_json']),
      observerIds: _parseStringList(json['observer_ids_json']),
      creatorIds: _parseStringList(json['creator_ids_json']),
      status: json['status'] ?? 'new',
      priority: json['priority'] ?? 'medium',
      dueDate: _parseDateTime(json['due_date']),
      completedAt: _parseDateTime(json['completed_at']),
      attachments: _parseMapList(json['attachments_json']),
      checklist: _parseMapList(json['checklist_json']),
      reminders: _parseMapList(json['reminders_json']),
      recurrence: _parseMap(json['recurrence_json']),
      options: _parseMap(json['options_json']) ?? {},
      holidayTransferRule: json['holiday_transfer_rule'],
      originTaskId: json['origin_task_id'],
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']) ?? DateTime.now(),
      relativeDates: _parseMap(json['relative_dates']),
    );
  }

  Map<String, dynamic> toJson() {
    String? formatDateTime(DateTime? dt) {
      if (dt == null) return null;
      final str = dt.toUtc().toIso8601String();
      // Remove milliseconds if present
      final parts = str.split('.');
      final noMs = parts.first;
      return noMs.endsWith('Z') ? noMs : '${noMs}Z';
    }

    return {
      if (id.isEmpty || id == 'new') 'task_id': id,
      'title': title,
      'description': description,
      'client_ids_json': jsonEncode(clientIds),
      'assignee_ids_json': jsonEncode(assigneeIds),
      'observer_ids_json': jsonEncode(observerIds),
      'creator_ids_json': jsonEncode(creatorIds),
      'status': status,
      'priority': priority,
      'due_date': formatDateTime(dueDate),
      'completed_at': formatDateTime(completedAt),
      'attachments_json': jsonEncode(attachments),
      'checklist_json': jsonEncode(checklist),
      'reminders_json': jsonEncode(reminders),
      'recurrence_json': recurrence != null ? jsonEncode(recurrence) : null,
      'options_json': jsonEncode(options),
      'holiday_transfer_rule': holidayTransferRule,
      'origin_task_id': originTaskId,
      'created_at': formatDateTime(createdAt),
      'updated_at': formatDateTime(updatedAt),
      if (relativeDates != null) 'relative_dates': relativeDates,
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      clientIds: entity.clientIds,
      assigneeIds: entity.assigneeIds,
      observerIds: entity.observerIds,
      creatorIds: entity.creatorIds,
      status: entity.status,
      priority: entity.priority,
      dueDate: entity.dueDate,
      completedAt: entity.completedAt,
      attachments: entity.attachments,
      checklist: entity.checklist,
      reminders: entity.reminders,
      recurrence: entity.recurrence,
      options: entity.options,
      holidayTransferRule: entity.holidayTransferRule,
      originTaskId: entity.originTaskId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      relativeDates: entity.relativeDates,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      clientIds: clientIds,
      assigneeIds: assigneeIds,
      observerIds: observerIds,
      creatorIds: creatorIds,
      status: status,
      priority: priority,
      dueDate: dueDate,
      completedAt: completedAt,
      attachments: attachments,
      checklist: checklist,
      reminders: reminders,
      recurrence: recurrence,
      options: options,
      holidayTransferRule: holidayTransferRule,
      originTaskId: originTaskId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      relativeDates: relativeDates,
    );
  }

  static List<String> _parseStringList(dynamic json) {
    if (json == null) return [];
    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is List) {
          return decoded.cast<String>();
        }
      } catch (e) {
        return [];
      }
    }
    if (json is List) {
      return json.cast<String>();
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseMapList(dynamic json) {
    if (json == null) return [];
    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        return [];
      }
    }
    if (json is List) {
      return json.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Map<String, dynamic>? _parseMap(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (e) {
        return null;
      }
    }
    if (json is Map<String, dynamic>) {
      return json;
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic json) {
    if (json == null) return null;
    // Если приходит строка ISO-8601
    if (json is String) {
      try {
        final dt = DateTime.parse(json);
        return dt.toLocal();
      } catch (_) {
        return null;
      }
    }
    // Если приходит число (микросекунды или миллисекунды с эпохи)
    if (json is int) {
      try {
        // YDB timestamp == микросекунды
        // Если число похоже на миллисекунды (< 10^12), конвертируем как миллисекунды
        if (json.abs() < 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(
            json,
            isUtc: true,
          ).toLocal();
        }
        // Иначе считаем микросекунды
        return DateTime.fromMicrosecondsSinceEpoch(json, isUtc: true).toLocal();
      } catch (_) {
        return null;
      }
    }
    // Если приходит число с плавающей точкой
    if (json is double) {
      return _parseDateTime(json.toInt());
    }
    return null;
  }
}
