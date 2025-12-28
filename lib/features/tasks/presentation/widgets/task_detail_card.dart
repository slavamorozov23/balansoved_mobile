import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/tasks/domain/entities/task_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/tasks_table_helpers.dart';

class TaskDetailCard extends StatelessWidget {
  final TaskEntity task;
  final List<EmployeeEntity> employees;

  const TaskDetailCard({
    super.key,
    required this.task,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailBlock(
          context,
          label: 'Статус',
          value: TasksTableHelpers.translateStatus(task.status),
        ),
        _detailBlock(
          context,
          label: 'Приоритет',
          value: TasksTableHelpers.translatePriority(task.priority),
        ),
        _detailBlock(
          context,
          label: 'Клиенты',
          value: task.clientIds.isNotEmpty ? task.clientIds.join(', ') : '–',
        ),
        _detailBlock(
          context,
          label: 'Исполнители',
          value: TasksTableHelpers.formatEmployeeNames(
            task.assigneeIds,
            employees,
          ),
        ),
        _detailBlock(
          context,
          label: 'Наблюдатели',
          value: TasksTableHelpers.formatEmployeeNames(
            task.observerIds,
            employees,
          ),
        ),
        _detailBlock(
          context,
          label: 'Создатели',
          value: TasksTableHelpers.formatEmployeeNames(
            task.creatorIds,
            employees,
          ),
        ),
        _detailBlock(
          context,
          label: 'Срок',
          value: TaskDetailUtils.formatDate(task.dueDate),
        ),
        _detailBlock(
          context,
          label: 'Завершено',
          value: TaskDetailUtils.formatDate(task.completedAt),
        ),
        _detailBlock(
          context,
          label: 'Создано',
          value: TaskDetailUtils.formatDate(task.createdAt),
        ),
        _detailBlock(
          context,
          label: 'Обновлено',
          value: TaskDetailUtils.formatDate(task.updatedAt),
        ),
        _detailBlock(
          context,
          label: 'Вложения',
          value:
              task.attachments.isNotEmpty
                  ? 'Всего: ${task.attachments.length}'
                  : '–',
        ),
        _detailBlock(
          context,
          label: 'Чек-листы',
          value:
              task.checklist.isNotEmpty
                  ? 'Всего: ${task.checklist.length}'
                  : '–',
        ),
        _detailBlock(
          context,
          label: 'Напоминания',
          value:
              task.reminders.isNotEmpty
                  ? 'Всего: ${task.reminders.length}'
                  : '–',
        ),
        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Описание', style: titleStyle),
          const SizedBox(height: 6),
          Text(task.description!),
        ],
      ],
    );
  }

  Widget _detailBlock(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
