import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientVersionDateField extends StatelessWidget {
  final DateTime? date;

  const ClientVersionDateField({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;
    final value = date;

    return OfficeFieldFrame(
      label: 'Дата версии',
      watermarkIcon: Icons.event_note_outlined,
      accentColor: accent,
      dense: true,
      child:
          value == null
              ? const OfficeEmptyValue()
              : Text(
                TaskDetailUtils.formatDate(value),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: TaskStyles.textPrimary(colorScheme),
                ),
              ),
    );
  }
}
