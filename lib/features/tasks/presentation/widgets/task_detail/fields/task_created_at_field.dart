import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';

class TaskCreatedAtField extends StatelessWidget {
  final DateTime? date;

  const TaskCreatedAtField({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;

    return OfficeFieldFrame(
      label: 'Создано',
      watermarkIcon: Icons.edit_calendar_outlined,
      accentColor: accent,
      dense: true,
      child: OfficeDateValue(date: date, accentColor: accent),
    );
  }
}
