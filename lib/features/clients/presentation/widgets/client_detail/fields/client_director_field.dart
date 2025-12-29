import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientDirectorField extends StatelessWidget {
  final String? directorType;
  final String? directorName;
  final DateTime? directorStartDate;

  const ClientDirectorField({
    super.key,
    required this.directorType,
    required this.directorName,
    required this.directorStartDate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.tertiary;
    final valueStyle = TextStyle(
      color: TaskStyles.textPrimary(colorScheme),
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.35,
    );
    final type = directorType?.trim() ?? '';
    final name = directorName?.trim() ?? '';
    final hasDate = directorStartDate != null;
    final hasAny = type.isNotEmpty || name.isNotEmpty || hasDate;

    Widget body;
    if (!hasAny) {
      body = const OfficeEmptyValue();
    } else {
      final lines = <Widget>[];
      if (type.isNotEmpty) {
        lines.add(
          OfficeBulletLine(
            icon: Icons.badge_outlined,
            accentColor: accent,
            text: 'Тип: $type',
            textStyle: valueStyle,
          ),
        );
      }
      if (name.isNotEmpty) {
        lines.add(
          OfficeBulletLine(
            icon: Icons.person_outline,
            accentColor: accent,
            text: 'ФИО: $name',
            textStyle: valueStyle,
          ),
        );
      }
      if (hasDate) {
        lines.add(
          OfficeBulletLine(
            icon: Icons.calendar_today_outlined,
            accentColor: accent,
            text: 'С: ${TaskDetailUtils.formatDate(directorStartDate)}',
            textStyle: valueStyle,
          ),
        );
      }
      body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: lines);
    }

    return OfficeFieldFrame(
      label: 'Руководитель',
      watermarkIcon: Icons.person_outline,
      accentColor: accent,
      child: body,
    );
  }
}
