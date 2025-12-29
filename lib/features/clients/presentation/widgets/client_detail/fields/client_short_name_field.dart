import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientShortNameField extends StatelessWidget {
  final String? shortName;

  const ClientShortNameField({super.key, required this.shortName});

  @override
  Widget build(BuildContext context) {
    final value = shortName?.trim() ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;

    return OfficeFieldFrame(
      label: 'Сокращенное имя',
      watermarkIcon: Icons.short_text_outlined,
      accentColor: accent,
      dense: true,
      child:
          value.isEmpty
              ? const OfficeEmptyValue()
              : Text(
                value,
                style: TaskStyles.sidebarValueStyle(
                  colorScheme,
                ).copyWith(fontWeight: FontWeight.w400),
              ),
    );
  }
}
