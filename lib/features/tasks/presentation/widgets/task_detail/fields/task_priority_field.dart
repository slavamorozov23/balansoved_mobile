import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/tasks_table_helpers.dart';

class TaskPriorityField extends StatelessWidget {
  final String priority;

  const TaskPriorityField({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityText = TasksTableHelpers.translatePriority(priority);
    final priorityColor = TaskStyles.getPriorityColor(priority, colorScheme);

    return OfficeFieldFrame(
      label: 'Приоритет',
      watermarkIcon: Icons.star_outline_rounded,
      accentColor: priorityColor,
      child: Row(
        children: [
          OfficePriorityStars(priority: priority, color: priorityColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              priorityText,
              style: TextStyle(
                color: priorityColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
