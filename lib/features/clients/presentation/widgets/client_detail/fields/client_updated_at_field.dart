import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientUpdatedAtField extends StatelessWidget {
  final DateTime? date;

  const ClientUpdatedAtField({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.tertiary;
    final timeStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: TaskStyles.textPrimary(colorScheme),
    );
    final dateStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: TaskStyles.textBody(colorScheme),
    );
    final centerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      color: accent,
    );

    return OfficeFieldFrame(
      label: 'Обновлено',
      watermarkIcon: Icons.update_outlined,
      accentColor: accent,
      dense: true,
      child: OfficeClockDateTimeValue(
        date: date,
        accentColor: accent,
        timeTextStyle: timeStyle,
        dateTextStyle: dateStyle,
        centerLabelStyle: centerStyle,
      ),
    );
  }
}
