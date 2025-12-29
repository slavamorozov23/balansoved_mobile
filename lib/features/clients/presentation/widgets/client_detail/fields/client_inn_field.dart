import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientInnField extends StatelessWidget {
  final String? inn;

  const ClientInnField({super.key, required this.inn});

  @override
  Widget build(BuildContext context) {
    final value = inn?.trim() ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;

    return OfficeFieldFrame(
      label: 'ИНН',
      watermarkIcon: Icons.numbers_outlined,
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
