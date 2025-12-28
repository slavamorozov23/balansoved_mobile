import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';

class TaskDueDateField extends StatelessWidget {
  final DateTime? date;

  const TaskDueDateField({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.tertiary;

    return OfficeFieldFrame(
      label: 'Срок',
      watermarkIcon: Icons.event_available_outlined,
      accentColor: accent,
      dense: true,
      child: OfficeClockDateTimeValue(date: date, accentColor: accent),
    );
  }
}
