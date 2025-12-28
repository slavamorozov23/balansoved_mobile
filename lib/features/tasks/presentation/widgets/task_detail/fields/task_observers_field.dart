import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/employees/domain/entities/employee_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';

class TaskObserversField extends StatelessWidget {
  final List<String> observerIds;
  final List<EmployeeEntity> employees;

  const TaskObserversField({
    super.key,
    required this.observerIds,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.secondary;
    final names = resolveEmployeeNames(observerIds, employees);

    return OfficeFieldFrame(
      label: 'Наблюдатели',
      watermarkIcon: Icons.visibility_outlined,
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
