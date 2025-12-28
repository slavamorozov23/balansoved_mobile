import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';

class TaskCompletedAtField extends StatelessWidget {
  final DateTime? date;

  const TaskCompletedAtField({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;

    return OfficeFieldFrame(
      label: 'Завершено',
      watermarkIcon: Icons.fact_check_outlined,
      accentColor: accent,
      dense: true,
      child: OfficeClockDateTimeValue(date: date, accentColor: accent),
    );
  }
}
