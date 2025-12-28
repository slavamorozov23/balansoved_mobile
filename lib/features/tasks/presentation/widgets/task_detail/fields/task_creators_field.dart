import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class TaskCreatorsField extends StatelessWidget {
  final List<String> creatorIds;
  final List<EmployeeEntity> employees;

  const TaskCreatorsField({
    super.key,
    required this.creatorIds,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = TaskStyles.accentForegroundColor(colorScheme);
    final names = resolveEmployeeNames(creatorIds, employees);

    return OfficeFieldFrame(
      label: 'Создатели',
      watermarkIcon: Icons.assignment_ind_outlined,
      accentColor: accent,
      child:
          names.isEmpty
              ? const OfficeEmptyValue()
              : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in names)
                    OfficeNameTag(name: name, accentColor: accent),
                ],
              ),
    );
  }
}
