import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class TaskTitleField extends StatelessWidget {
  final String title;

  const TaskTitleField({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = TaskStyles.accentForegroundColor(colorScheme);

    return OfficeFieldFrame(
      label: 'Название',
      watermarkIcon: Icons.assignment_outlined,
      accentColor: accent,
      child: Text(
        title,
        style: TaskStyles.titleStyle(colorScheme).copyWith(fontSize: 20),
      ),
    );
  }
}
