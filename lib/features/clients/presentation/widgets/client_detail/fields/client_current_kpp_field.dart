import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/tasks/presentation/utils/task_detail_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_components.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/office/office_field_frame.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

class ClientCurrentKppField extends StatelessWidget {
  final List<KppInfo> kppInfo;

  const ClientCurrentKppField({super.key, required this.kppInfo});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    final currentKpp = kppInfo.isNotEmpty ? kppInfo.first : null;
    final colorScheme = Theme.of(context).colorScheme;
    final valueStyle = TextStyle(
      color: TaskStyles.textPrimary(colorScheme),
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 1.35,
    );

    Widget body;
    if (currentKpp == null) {
      body = const OfficeEmptyValue();
    } else {
      final number = currentKpp.number.trim();
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OfficeBulletLine(
            icon: Icons.credit_card_outlined,
            accentColor: accent,
            text: number.isEmpty ? 'Номер: –' : 'Номер: $number',
            textStyle: valueStyle,
          ),
          OfficeBulletLine(
            icon: Icons.event_outlined,
            accentColor: accent,
            text: 'Дата: ${TaskDetailUtils.formatDate(currentKpp.date)}',
            textStyle: valueStyle,
          ),
        ],
      );
    }

    return OfficeFieldFrame(
      label: 'Текущий КПП',
      watermarkIcon: Icons.pin_outlined,
      accentColor: accent,
      dense: true,
      child: body,
    );
  }
}
