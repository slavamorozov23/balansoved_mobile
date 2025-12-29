import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientPatentsField extends StatelessWidget {
  final List<PatentEntity> patents;

  const ClientPatentsField({super.key, required this.patents});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.tertiary;
    final count = patents.length;
    final valueStyle = TextStyle(
      color: TaskStyles.textPrimary(colorScheme),
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.35,
    );

    final headlineStyle = TextStyle(
      fontWeight: FontWeight.w400,
      color: TaskStyles.textPrimary(colorScheme),
    );

    return OfficeFieldFrame(
      label: 'Патенты',
      watermarkIcon: Icons.copyright_outlined,
      accentColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count > 0 ? 'Патентов: $count' : 'Патентов нет',
            style: headlineStyle,
          ),
          if (count > 0) ...[
            const SizedBox(height: 10),
            for (final item in patents.take(3))
              OfficeBulletLine(
                icon: Icons.assignment_turned_in_outlined,
                accentColor: accent,
                text: _patentLabel(item),
                textStyle: valueStyle,
              ),
            if (count > 3)
              Text(
                'и ещё ${count - 3}',
                style: TextStyle(
                  color: TaskStyles.textMuted(colorScheme),
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String _patentLabel(PatentEntity patent) {
  final title =
      (patent.patentTitle?.trim().isNotEmpty ?? false)
          ? patent.patentTitle!.trim()
          : 'Патент';
  final number = patent.patentNumber.trim();
  final start = TaskDetailUtils.formatDate(patent.startDate);
  final end = TaskDetailUtils.formatDate(patent.endDate);
  final numberText = number.isEmpty ? '' : ' №$number';
  return '$title$numberText · $start – $end';
}
