import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientCreationDateField extends StatelessWidget {
  final DateTime? date;

  const ClientCreationDateField({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;

    return OfficeFieldFrame(
      label: 'Дата регистрации',
      watermarkIcon: Icons.calendar_today_outlined,
      accentColor: accent,
      dense: true,
      child:
          date == null
              ? const OfficeEmptyValue()
              : Text(
                TaskDetailUtils.formatDate(date),
                style: TaskStyles.sidebarValueStyle(
                  colorScheme,
                ).copyWith(fontWeight: FontWeight.w400),
              ),
    );
  }
}
