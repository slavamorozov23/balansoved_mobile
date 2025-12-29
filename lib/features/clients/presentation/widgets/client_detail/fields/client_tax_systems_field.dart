import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientTaxSystemsField extends StatelessWidget {
  final List<String> taxSystems;

  const ClientTaxSystemsField({super.key, required this.taxSystems});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.tertiary;
    final clean =
        taxSystems.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final valueStyle = TextStyle(
      color: TaskStyles.textPrimary(colorScheme),
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.35,
    );

    return OfficeFieldFrame(
      label: 'Система налогообложения',
      watermarkIcon: Icons.receipt_long_outlined,
      accentColor: accent,
      child:
          clean.isEmpty
              ? const OfficeEmptyValue()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final tax in clean)
                    OfficeBulletLine(
                      icon: Icons.check_circle_outline,
                      accentColor: accent,
                      text: tax,
                      textStyle: valueStyle,
                    ),
                ],
              ),
    );
  }
}
