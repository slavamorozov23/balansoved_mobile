import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientOwnershipFormField extends StatelessWidget {
  final String? ownershipForm;

  const ClientOwnershipFormField({super.key, required this.ownershipForm});

  @override
  Widget build(BuildContext context) {
    final value = ownershipForm?.trim() ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;

    return OfficeFieldFrame(
      label: 'Форма собственности',
      watermarkIcon: Icons.apartment_outlined,
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
