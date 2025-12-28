import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class TaskRemindersField extends StatelessWidget {
  final List<Map<String, dynamic>> reminders;

  const TaskRemindersField({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.tertiary;
    final sorted = List<Map<String, dynamic>>.from(reminders)
      ..sort(_compareReminderDates);
    final activeIndex = _findActiveReminderIndex(sorted);
    final count = sorted.length;

    final headlineStyle = TextStyle(
      fontWeight: FontWeight.w800,
      color: TaskStyles.textPrimary(colorScheme),
    );

    return OfficeFieldFrame(
      label: 'Напоминания',
      watermarkIcon: Icons.notifications_outlined,
      accentColor: accent,
      decorationVariant: OfficeFieldFrameDecorationVariant.note,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count > 0 ? 'Напоминаний: $count' : 'Напоминаний нет',
            style: headlineStyle,
          ),
          if (count > 0) ...[
            const SizedBox(height: 10),
            for (final entry in sorted.take(5).toList().indexed)
              _ReminderLine(
                reminder: entry.$2,
                accentColor: accent,
                ringing: activeIndex == entry.$1,
              ),
            if (count > 5)
              Text(
                'и ещё ${count - 5}',
                style: TextStyle(
                  color: TaskStyles.textMuted(colorScheme),
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ReminderLine extends StatelessWidget {
  final Map<String, dynamic> reminder;
  final Color accentColor;
  final bool ringing;

  const _ReminderLine({
    required this.reminder,
    required this.accentColor,
    required this.ringing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final role = _reminderRole(reminder);
    final roleIcon = _roleIcon(role);
    final roleLabel = _roleLabel(role);

    final bellIcon =
        ringing ? Icons.notifications_active_outlined : Icons.notifications_none_outlined;

    final iconColor =
        ringing ? accentColor.withValues(alpha: 0.95) : accentColor.withValues(alpha: 0.75);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(bellIcon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Роль: $roleLabel',
          waitDuration: const Duration(milliseconds: 450),
          child: Icon(
            roleIcon,
            size: 16,
            color: accentColor.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _reminderLabel(reminder),
            style: TextStyle(
              color: TaskStyles.textPrimary(colorScheme),
              fontWeight: ringing ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

String _reminderLabel(Map<String, dynamic> item) {
  const textKeys = ['title', 'text', 'message', 'body', 'name'];
  const whenKeys = [
    'date',
    'datetime',
    'at',
    'when',
    'time',
    'remind_at',
    'remindAt',
  ];

  String? text;
  for (final k in textKeys) {
    final v = item[k];
    if (v is String && v.trim().isNotEmpty) {
      text = v.trim();
      break;
    }
  }

  dynamic when;
  for (final k in whenKeys) {
    final v = item[k];
    if (v == null) continue;
    if (v is String && v.trim().isNotEmpty) {
      when = v.trim();
      break;
    }
    if (v is num) {
      when = v;
      break;
    }
  }

  final whenFormatted = _formatReminderWhen(when);

  if (whenFormatted != null && text != null) return '$whenFormatted — $text';
  if (text != null) return text;
  if (whenFormatted != null) return whenFormatted;
  return 'Напоминание';
}

String? _formatReminderWhen(dynamic raw) {
  if (raw == null) return null;

  DateTime? dateTime;
  if (raw is DateTime) {
    dateTime = raw;
  } else if (raw is num) {
    dateTime = _dateTimeFromEpoch(raw);
  } else if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    dateTime = DateTime.tryParse(trimmed);
    dateTime ??= _tryParseEpochString(trimmed);
    if (dateTime == null) return trimmed;
  } else {
    return raw.toString();
  }

  final local = dateTime.toLocal();
  final time = DateFormat('HH:mm').format(local);
  final date = DateFormat('dd.MM.yyyy').format(local);
  return '$time · $date';
}

DateTime? _tryParseEpochString(String raw) {
  final n = num.tryParse(raw);
  if (n == null) return null;
  return _dateTimeFromEpoch(n);
}

DateTime _dateTimeFromEpoch(num value) {
  final abs = value.abs();
  // seconds: 1e9..1e10, ms: 1e12..1e13, μs: 1e15..
  if (abs >= 1000000000000000) {
    return DateTime.fromMicrosecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  if (abs >= 1000000000000) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  return DateTime.fromMillisecondsSinceEpoch(
    (value * 1000).toInt(),
    isUtc: true,
  );
}

DateTime? _extractReminderDateTime(Map<String, dynamic> item) {
  const whenKeys = [
    'datetime',
    'date',
    'at',
    'when',
    'time',
    'remind_at',
    'remindAt',
  ];

  for (final k in whenKeys) {
    final v = item[k];
    if (v == null) continue;
    if (v is DateTime) return v.toLocal();
    if (v is num) return _dateTimeFromEpoch(v).toLocal();
    if (v is String && v.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(v.trim());
      if (parsed != null) return parsed.toLocal();
      final epoch = num.tryParse(v.trim());
      if (epoch != null) return _dateTimeFromEpoch(epoch).toLocal();
      return null;
    }
  }

  return null;
}

int _compareReminderDates(Map<String, dynamic> a, Map<String, dynamic> b) {
  final da = _extractReminderDateTime(a);
  final db = _extractReminderDateTime(b);
  if (da == null && db == null) return 0;
  if (da == null) return 1;
  if (db == null) return -1;
  return da.compareTo(db);
}

int? _findActiveReminderIndex(List<Map<String, dynamic>> reminders) {
  if (reminders.isEmpty) return null;

  final now = DateTime.now();

  int? bestTodayIndex;
  DateTime? bestTodayDateTime;
  bool bestTodayIsFuture = false;

  for (var i = 0; i < reminders.length; i++) {
    final dt = _extractReminderDateTime(reminders[i]);
    if (dt == null) continue;
    if (!_isSameDay(dt, now)) continue;

    final isFutureOrNow = !dt.isBefore(now);
    if (bestTodayDateTime == null) {
      bestTodayIndex = i;
      bestTodayDateTime = dt;
      bestTodayIsFuture = isFutureOrNow;
      continue;
    }

    if (bestTodayIsFuture) {
      if (isFutureOrNow && dt.isBefore(bestTodayDateTime)) {
        bestTodayIndex = i;
        bestTodayDateTime = dt;
      }
      continue;
    }

    if (isFutureOrNow) {
      bestTodayIndex = i;
      bestTodayDateTime = dt;
      bestTodayIsFuture = true;
      continue;
    }

    if (dt.isAfter(bestTodayDateTime)) {
      bestTodayIndex = i;
      bestTodayDateTime = dt;
    }
  }

  if (bestTodayIndex != null) return bestTodayIndex;

  int? bestFutureIndex;
  DateTime? bestFutureDateTime;
  for (var i = 0; i < reminders.length; i++) {
    final dt = _extractReminderDateTime(reminders[i]);
    if (dt == null) continue;
    if (dt.isBefore(now)) continue;

    if (bestFutureDateTime == null || dt.isBefore(bestFutureDateTime)) {
      bestFutureDateTime = dt;
      bestFutureIndex = i;
    }
  }

  return bestFutureIndex;
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String? _reminderRole(Map<String, dynamic> item) {
  final raw =
      item['role'] ?? item['recipient_role'] ?? item['target_role'] ?? item['for_role'];
  return raw?.toString();
}

String _roleLabel(String? role) {
  switch (role) {
    case 'assignee':
      return 'Исполнитель';
    case 'observer':
      return 'Наблюдатель';
    case 'creator':
      return 'Постановщик';
    default:
      return role == null || role.trim().isEmpty ? 'Не указано' : role;
  }
}

IconData _roleIcon(String? role) {
  switch (role) {
    case 'assignee':
      return TaskStyles.assigneeIcon;
    case 'observer':
      return TaskStyles.observersIcon;
    case 'creator':
      return TaskStyles.creatorIcon;
    default:
      return Icons.badge_outlined;
  }
}
