import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:balansoved_mobile/features/notifications/domain/entities/notification_entity.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onOpenTask;
  final VoidCallback? onMarkAsDelivered;
  final bool isOpeningTask;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onOpenTask,
    this.onMarkAsDelivered,
    this.isOpeningTask = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd.MM.yyyy');

    final String? taskId = _extractTaskId(notification.additionalInfo);
    final String displayTitle = _resolveTitle(notification);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            notification.isDelivered
                ? colorScheme.surface
                : colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              notification.isDelivered
                  ? colorScheme.outline.withValues(alpha: 0.3)
                  : colorScheme.primary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color:
                          notification.isDelivered
                              ? colorScheme.outline.withValues(alpha: 0.5)
                              : colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight:
                            notification.isDelivered
                                ? FontWeight.normal
                                : FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dateFormat.format(notification.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (taskId != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child:
                                  isOpeningTask
                                      ? const Padding(
                                        padding: EdgeInsets.all(6),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : IconButton(
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        iconSize: 20,
                                        onPressed: onOpenTask,
                                        icon: Icon(
                                          Icons.open_in_new,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              iconSize: 20,
                              tooltip: 'Отметить как прочитанное',
                              onPressed: onMarkAsDelivered,
                              icon: Icon(
                                Icons.close,
                                color:
                                    colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  notification.body ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _extractTaskId(Map<String, dynamic>? additionalInfo) {
    if (additionalInfo == null) return null;
    final dynamic value = additionalInfo['task_id'] ?? additionalInfo['taskId'];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  String _resolveTitle(NotificationEntity n) {
    final Map<String, dynamic>? add = n.additionalInfo;
    if (add != null) {
      final dynamic v = add['body'] ?? add['text'];
      if (v is String && v.trim().isNotEmpty) {
        return v;
      }
    }
    return n.title ?? '';
  }
}
