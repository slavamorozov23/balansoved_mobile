import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientNameField extends StatelessWidget {
  final String name;

  const ClientNameField({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = TaskStyles.accentForegroundColor(colorScheme);

    return OfficeFieldFrame(
      label: 'Наименование',
      watermarkIcon: Icons.business_outlined,
      accentColor: accent,
      child: Text(
        name,
        style: TaskStyles.titleStyle(
          colorScheme,
        ).copyWith(fontSize: 20, fontWeight: FontWeight.w400),
      ),
    );
  }
}
