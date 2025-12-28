import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';

class TaskAssigneesField extends StatelessWidget {
  final List<String> assigneeIds;
  final List<EmployeeEntity> employees;

  const TaskAssigneesField({
    super.key,
    required this.assigneeIds,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    final names = resolveEmployeeNames(assigneeIds, employees);

    return OfficeFieldFrame(
      label: 'Исполнители',
      watermarkIcon: Icons.person_outline,
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
